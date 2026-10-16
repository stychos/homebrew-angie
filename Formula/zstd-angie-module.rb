class ZstdAngieModule < Formula
  desc "Zstandard compression module for angie-full"
  homepage "https://github.com/myguard-labs/nginx-zstd-module"
  url "https://github.com/myguard-labs/nginx-zstd-module/archive/refs/tags/0.90.9.tar.gz"
  sha256 "1e1948eea1d0114b2081a7e36951e284987f4c94050f98515fabb410cf0af219"
  license "BSD-2-Clause"

  depends_on "zstd"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
