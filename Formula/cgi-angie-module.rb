class CgiAngieModule < Formula
  desc "CGI module (pjincz/nginx-cgi) for angie-full"
  homepage "https://github.com/pjincz/nginx-cgi"
  url "https://github.com/pjincz/nginx-cgi/archive/refs/tags/v0.15.2.tar.gz"
  sha256 "6925ae8f2a3081fe49e8d31d5e6c8e64222bbd0d8681b880ae1bde7650f36ee6"
  license "BSD-2-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
