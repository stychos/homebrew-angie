class ModsecurityAngieModule < Formula
  desc "ModSecurity v3 connector module for angie-full"
  homepage "https://github.com/owasp-modsecurity/ModSecurity-nginx"
  url "https://github.com/owasp-modsecurity/ModSecurity-nginx/archive/refs/tags/v1.0.4.tar.gz"
  sha256 "bb596d146ad0650014168dda9dc8d07c50a070010044c95ed0d167a9a78e63a1"
  license "Apache-2.0"

  depends_on "modsecurity"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
