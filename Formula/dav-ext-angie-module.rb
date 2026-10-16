class DavExtAngieModule < Formula
  desc "WebDAV extensions (PROPFIND, OPTIONS, LOCK) module for angie-full"
  homepage "https://github.com/arut/nginx-dav-ext-module"
  url "https://github.com/arut/nginx-dav-ext-module/archive/refs/tags/v3.0.0.tar.gz"
  sha256 "d2499d94d82d4e4eac8425d799e52883131ae86a956524040ff2fd230ef9f859"
  license "BSD-2-Clause"

  depends_on "libxml2"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
