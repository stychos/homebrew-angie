#!/bin/bash
#
# Build, bottle and publish Angie bottles for the macOS release of *this*
# machine. Use it for macOS versions that GitHub Actions does not host yet
# (e.g. macOS 27 "Golden Gate"); .github/workflows/publish.yml covers the rest.
#
# For angie and angie-full (they conflict, so one after the other):
#   1. Rebuilds the formula from source with --build-bottle. Whichever of the
#      two was installed is replaced; an already running angie is not touched.
#   2. Runs `brew bottle` -> bottles/<formula>-<version>.<tag>.bottle.tar.gz
#   3. Uploads the tarball to the GitHub release named after the Angie version.
#      Needs either a logged-in `gh`, or GITHUB_TOKEN / HOMEBREW_GITHUB_API_TOKEN
#      with write access to the repo. Skipped with --no-upload.
#   4. Adds (or replaces) the tag's sha256 line in the formula's bottle block
#      for that version (bottle-block.rb). Review the diff, then commit.
#
# Usage: ./scripts/bottle-local.sh [--no-build] [--no-upload] [--only angie|angie-full]
#   --no-build   reuse the installed keg (it must have been built with
#                --build-bottle); only the installed formula is bottled
#   --no-upload  build and update the formulae only; upload the tarballs later
#   --only       handle just one of the two formulae
#
# The formula built last stays installed. To switch back to the other one:
#   brew uninstall angie-full && brew install stychos/angie/angie

set -euo pipefail

tap="stychos/angie"
repo="stychos/homebrew-angie"
out_dir="bottles"
formulae=(angie angie-full)

do_build=1
do_upload=1
while (($#))
do
  case "$1" in
    --no-build) do_build=0 ;;
    --no-upload) do_upload=0 ;;
    --only)
      shift
      formulae=("$1")
      ;;
    *)
      echo "unknown option: $1" >&2
      exit 2
      ;;
  esac
  shift
done

cd "$(dirname "$0")/.."

# conflicts_with makes each formula load the other, which Homebrew only allows from a trusted tap
brew trust --tap "${tap}" >/dev/null

version=$(brew info --json=v1 "${tap}/angie" | grep -oE '"stable": *"[^"]+"' | head -1 | cut -d'"' -f4)
tag=$(brew ruby -e 'puts Utils::Bottles.tag')
root_url="https://github.com/${repo}/releases/download/${version}"
mkdir -p "${out_dir}"

if ((! do_build))
then
  installed=()
  for formula in "${formulae[@]}"
  do
    brew list --versions "${formula}" >/dev/null 2>&1 && installed+=("${formula}")
  done
  if ((${#installed[@]} == 0))
  then
    echo "!!> --no-build needs an installed angie or angie-full keg" >&2
    exit 1
  fi
  formulae=("${installed[@]}")
fi

upload() {
  local tarball=$1 asset token
  asset=$(basename "${tarball}")
  token="${GITHUB_TOKEN:-${HOMEBREW_GITHUB_API_TOKEN:-}}"
  if command -v gh >/dev/null && gh auth status >/dev/null 2>&1
  then
    echo "==> Uploading ${asset} to release ${version} with gh"
    gh release upload --clobber --repo "${repo}" "${version}" "${tarball}"
  elif [[ -n "${token}" ]]
  then
    echo "==> Uploading ${asset} to release ${version} with the GitHub API"
    local api auth release_json ids release_id asset_id
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
    echo "!!> No GitHub credentials (gh login or GITHUB_TOKEN); upload the bottles later with:" >&2
    echo "    gh release upload --clobber --repo ${repo} ${version} ${out_dir}/*.bottle.tar.gz" >&2
    do_upload=0
  fi
}

for formula in "${formulae[@]}"
do
  echo "==> ${formula} ${version}, bottle tag ${tag}"
  if ((do_build))
  then
    for other in angie angie-full
    do
      if brew list --versions "${other}" >/dev/null 2>&1
      then
        echo "==> Uninstalling ${other} (a running angie keeps running)"
        brew uninstall --ignore-dependencies "${other}"
      fi
    done
    echo "==> Building ${formula} from source with --build-bottle"
    if ! brew install --build-bottle "${tap}/${formula}"
    then
      echo "!!> Build failed; reinstalling ${formula} from the published bottle" >&2
      brew install "${tap}/${formula}" || true
      exit 1
    fi
  fi

  # the package version includes a _revision suffix when the formula has one
  pkgver=$(brew ruby -e "puts Formula['${tap}/${formula}'].pkg_version")
  tarball="${out_dir}/${formula}-${pkgver}.${tag}.bottle.tar.gz"
  echo "==> Bottling into ${out_dir}/"
  rm -f "${tarball}"
  (
    cd "${out_dir}"
    brew bottle --no-rebuild --root-url="${root_url}" "${tap}/${formula}"
    for f in ./*--*.bottle.*; do mv -f "${f}" "${f//--/-}"; done
  )
  sha256=$(shasum -a 256 "${tarball}" | cut -d ' ' -f1)
  echo "    ${tarball}"
  echo "    sha256 ${sha256}"

  if ((do_upload))
  then
    upload "${tarball}"
  fi

  echo "==> Updating the ${version} bottle block in Formula/${formula}.rb"
  brew ruby ./scripts/bottle-block.rb "Formula/${formula}.rb" "${version}" "${root_url}" "${tag}=${sha256}"
done

git --no-pager diff --stat -- Formula/angie.rb Formula/angie-full.rb
echo "==> Done. Next:"
((do_upload)) || echo "    upload ${out_dir}/*.bottle.tar.gz to release ${version} (see above)"
echo "    git diff Formula/ && git commit -m 'updated bottles list' Formula/angie.rb Formula/angie-full.rb"
