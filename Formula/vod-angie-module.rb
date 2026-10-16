class VodAngieModule < Formula
  desc "VOD on-the-fly MP4/HLS/DASH repackaging module for angie-full"
  homepage "https://github.com/dio-az/nginx-vod-module"
  url "https://github.com/dio-az/nginx-vod-module/archive/refs/tags/v1.10.1.tar.gz"
  sha256 "7ca0da03b57377366d9237308ef3e0c8971c92ee7b6a1d427393dba1d096ec45"
  license "AGPL-3.0-only"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
