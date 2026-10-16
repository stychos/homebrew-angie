class OidcAngieModule < Formula
  desc "OpenID Connect module (kjdev/nginx-oidc) for angie-full"
  homepage "https://github.com/kjdev/nginx-oidc"
  url "https://github.com/kjdev/nginx-oidc.git",
      tag:      "0.8.0",
      revision: "a9bbb082bef032376edf678c646cbc0ba527551a"
  license "MIT"

  depends_on "hiredis"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
