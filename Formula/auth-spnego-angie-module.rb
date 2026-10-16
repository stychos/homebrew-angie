class AuthSpnegoAngieModule < Formula
  desc "SPNEGO/Kerberos authentication module for angie-full"
  homepage "https://github.com/stnoonan/spnego-http-auth-nginx-module"
  url "https://github.com/stnoonan/spnego-http-auth-nginx-module/archive/refs/tags/v1.1.3.tar.gz"
  sha256 "0e1e54f8ab7d76f922881f13d870edf8b820ef645b19013774c825110d011640"
  license "BSD-2-Clause"

  depends_on "krb5"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
