class AuthPamAngieModule < Formula
  desc "PAM authentication module for angie-full"
  homepage "https://github.com/sto/ngx_http_auth_pam_module"
  url "https://github.com/sto/ngx_http_auth_pam_module/archive/refs/tags/v1.5.5.tar.gz"
  sha256 "98a71617d9119ae784993e3789ce8766fdf2ff2479691f3dc6cf8d8763f8d364"
  license "BSD-2-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
