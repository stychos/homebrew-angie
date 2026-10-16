class SubsAngieModule < Formula
  desc "Substitutions filter module for angie-full"
  homepage "https://github.com/yaoweibin/ngx_http_substitutions_filter_module"
  # master supports PCRE2; the last tag (v0.6.4, 2015) does not
  url "https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/e12e965ac1837ca709709f9a26f572a54d83430e.tar.gz"
  version "2022.01.24"
  sha256 "da2a26aa75884e1216941c7291b6e8b7fc4dd7163700a04191b92060b61fabb3"

  livecheck do
    skip "Upstream's tags predate the pinned commit"
  end

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
