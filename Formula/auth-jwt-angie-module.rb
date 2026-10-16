class AuthJwtAngieModule < Formula
  desc "JWT authentication module (kjdev/nginx-auth-jwt) for angie-full"
  homepage "https://github.com/kjdev/nginx-auth-jwt"
  url "https://github.com/kjdev/nginx-auth-jwt.git",
      tag:      "0.15.0",
      revision: "76e0be21811332e3d49c81ec72900b38a9661732"
  license "MIT"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
