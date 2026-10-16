class AuthLdapAngieModule < Formula
  desc "LDAP authentication module for angie-full"
  homepage "https://github.com/kvspb/nginx-auth-ldap"
  url "https://github.com/kvspb/nginx-auth-ldap/archive/241200eac8e4acae74d353291bd27f79e5ca3dc4.tar.gz"
  version "2024.04.24"
  sha256 "d1b36b0973bc4089d3e1035679486ac286a0118df39dad0da399a6016e0ccc5b"
  license "BSD-2-Clause"

  depends_on "openldap"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
