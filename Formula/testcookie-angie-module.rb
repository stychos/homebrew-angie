class TestcookieAngieModule < Formula
  desc "Cookie-based DDoS protection module for angie-full"
  homepage "https://github.com/kyprizel/testcookie-nginx-module"
  url "https://github.com/kyprizel/testcookie-nginx-module/archive/7d263d4322b7de6b99b486e5e10ecaf0295890ad.tar.gz"
  version "2026.05.18"
  sha256 "679dc915b464c791fe7ae27a610ca38f3a0b40a68c4b24fbcbb835d232224fc0"

  livecheck do
    skip "Upstream has no tagged releases; pinned to a commit"
  end

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
