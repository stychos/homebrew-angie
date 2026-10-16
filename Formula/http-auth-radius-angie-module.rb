class HttpAuthRadiusAngieModule < Formula
  desc "RADIUS authentication module for angie-full"
  homepage "https://github.com/ten0s/ngx_http_auth_radius_module"
  url "https://github.com/ten0s/ngx_http_auth_radius_module/archive/458af16e01533d52b842c74f242fff2340104385.tar.gz"
  version "2024.06.14"
  sha256 "49195d489989472e2127d82c6efa404f0efe88c8d816fb904e2573485767a452"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
