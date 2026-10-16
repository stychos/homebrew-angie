class StreamStsAngieModule < Formula
  desc "Stream server traffic status module (stream part) for angie-full"
  homepage "https://github.com/vozlt/nginx-module-stream-sts"
  url "https://github.com/vozlt/nginx-module-stream-sts/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "6c47bdf044236db60a053777348bd50912ee1712ff420057cafd6f732193b6e8"
  license "BSD-2-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
