class UnzstdAngieModule < Formula
  desc "Zstandard decompression filter module for angie-full"
  homepage "https://github.com/HanadaLee/ngx_http_unzstd_filter_module"
  url "https://github.com/HanadaLee/ngx_http_unzstd_filter_module/archive/8137c6b05131d045619d1746d3bbc17623c9a8fb.tar.gz"
  version "2026.09.25"
  sha256 "72f9690e1ae11e49aeeb446a4e4a25e155a0781793a4b7cc15a85d0941a2a419"
  license "BSD-2-Clause"

  livecheck do
    skip "Upstream has no tagged releases; pinned to a commit"
  end

  depends_on "zstd"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
