#!/bin/bash
#
# Build, bottle and publish an Angie bottle for the macOS release of *this*
# machine. Use it for macOS versions that GitHub Actions does not host yet
# (e.g. macOS 27 "Golden Gate"); .github/workflows/publish.yml covers the rest.
#
# What it does:
#   1. Rebuilds angie from source with --build-bottle. The installed keg is
#      replaced by the fresh build; an already running angie is not touched.
#   2. Runs `brew bottle` -> bottles/angie-<version>.<tag>.bottle.tar.gz
#   3. Uploads the tarball to the GitHub release named after the version.
#      Needs either a logged-in `gh`, or GITHUB_TOKEN / HOMEBREW_GITHUB_API_TOKEN
#      with write access to the repo. Skipped with --no-upload.
#   4. Adds (or replaces) the tag's sha256 line in the formula's bottle block
#      for that version. Review the diff, then commit Formula/angie.rb.
#
# Usage: ./bottle-local.sh [--no-build] [--no-upload]
#   --no-build   reuse the installed keg (it must have been built with --build-bottle)
#   --no-upload  build and update the formula only; upload the tarball later

set -euo pipefail

formula="stychos/angie/angie"
repo="stychos/homebrew-angie"
formula_file="Formula/angie.rb"
out_dir="bottles"

do_build=1
do_upload=1
for arg in "$@"
do
  case "${arg}" in
    --no-build) do_build=0 ;;
    --no-upload) do_upload=0 ;;
    *)
      echo "unknown option: ${arg}" >&2
      exit 2
      ;;
  esac
done

cd "$(dirname "$0")"

version=$(brew info --json=v1 "${formula}" | grep -oE '"stable": *"[^"]+"' | head -1 | cut -d'"' -f4)
tag=$(brew ruby -e 'puts Utils::Bottles.tag')
root_url="https://github.com/${repo}/releases/download/${version}"
tarball="${out_dir}/angie-${version}.${tag}.bottle.tar.gz"
echo "==> angie ${version}, bottle tag ${tag}"

# 1. Build
if ((do_build))
then
  if brew list --versions angie >/dev/null 2>&1
  then
    echo "==> Uninstalling the installed angie keg (a running angie keeps running)"
    brew uninstall --ignore-dependencies angie
  fi
  echo "==> Building angie ${version} from source with --build-bottle"
  if ! brew install --build-bottle "${formula}"
  then
    echo "!!> Build failed; reinstalling angie from the published bottle" >&2
    brew install "${formula}" || true
    exit 1
  fi
fi

# 2. Bottle
echo "==> Bottling into ${out_dir}/"
mkdir -p "${out_dir}"
rm -f "${tarball}"
(
  cd "${out_dir}"
  brew bottle --no-rebuild --root-url="${root_url}" "${formula}"
  for f in ./angie--*.bottle.*; do mv -f "${f}" "${f//--/-}"; done
)
sha256=$(shasum -a 256 "${tarball}" | cut -d ' ' -f1)
echo "    ${tarball}"
echo "    sha256 ${sha256}"

# 3. Upload
if ((do_upload))
then
  asset=$(basename "${tarball}")
  token="${GITHUB_TOKEN:-${HOMEBREW_GITHUB_API_TOKEN:-}}"
  if command -v gh >/dev/null && gh auth status >/dev/null 2>&1
  then
    echo "==> Uploading ${asset} to release ${version} with gh"
    gh release upload --clobber --repo "${repo}" "${version}" "${tarball}"
  elif [[ -n "${token}" ]]
  then
    echo "==> Uploading ${asset} to release ${version} with the GitHub API"
    api="https://api.github.com/repos/${repo}/releases"
    auth="Authorization: Bearer ${token}"
    release_json=$(curl -fsS -H "${auth}" "${api}/tags/${version}")
    ids=$(
      brew ruby -rjson - "${asset}" "${release_json}" <<'RUBY'
release = JSON.parse(ARGV[1])
old = release["assets"].find { |a| a["name"] == ARGV[0] }
puts [release["id"], old ? old["id"] : "-"].join(" ")
RUBY
    )
    release_id=${ids%% *}
    asset_id=${ids##* }
    if [[ "${asset_id}" != "-" ]]
    then
      curl -fsS -X DELETE -H "${auth}" "${api}/assets/${asset_id}"
    fi
    curl -fsS -X POST -H "${auth}" -H "Content-Type: application/gzip" \
      --data-binary @"${tarball}" \
      "https://uploads.github.com/repos/${repo}/releases/${release_id}/assets?name=${asset}" >/dev/null
  else
    echo "!!> No GitHub credentials (gh login or GITHUB_TOKEN); upload the bottle later with:" >&2
    echo "    gh release upload --clobber --repo ${repo} ${version} ${tarball}" >&2
    do_upload=0
  fi
fi

# 4. Formula
echo "==> Updating the ${version} bottle block in ${formula_file}"
brew ruby ./bottle-block.rb "${formula_file}" "${version}" "${root_url}" "${tag}=${sha256}"

git --no-pager diff --stat -- "${formula_file}"
echo "==> Done. Next:"
((do_upload)) || echo "    upload ${tarball} to release ${version} (see above)"
echo "    git diff ${formula_file} && git commit -m 'updated bottles list' ${formula_file}"
