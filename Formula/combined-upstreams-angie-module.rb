class CombinedUpstreamsAngieModule < Formula
  desc "Combined upstreams module for angie-full"
  homepage "https://github.com/lyokha/nginx-combined-upstreams-module"
  url "https://github.com/lyokha/nginx-combined-upstreams-module/archive/refs/tags/2.3.1.tar.gz"
  sha256 "d6b1532bedb599af3bc74cb3d1e2b8c1a009f366261fa9ff8d7781156576bdfc"
  license "BSD-2-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
