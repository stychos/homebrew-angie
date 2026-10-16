class AuthTotpAngieModule < Formula
  desc "Time-based one-time password authentication module for angie-full"
  homepage "https://github.com/61131/nginx-http-auth-totp"
  url "https://github.com/61131/nginx-http-auth-totp/archive/refs/tags/1.2.0.tar.gz"
  sha256 "630e599c5ca16691689230a8b40a6db0d2878a1112be641fa50d68a7d8551651"
  license "MIT"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
