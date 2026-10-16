class RtmpAngieModule < Formula
  desc "RTMP streaming module for angie-full"
  homepage "https://github.com/arut/nginx-rtmp-module"
  url "https://github.com/arut/nginx-rtmp-module/archive/refs/tags/v1.2.2.tar.gz"
  sha256 "07f19b7bffec5e357bb8820c63e5281debd45f5a2e6d46b1636d9202c3e09d78"
  license "BSD-2-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
