class Geoip2AngieModule < Formula
  desc "GeoIP2 (libmaxminddb) module for angie-full"
  homepage "https://github.com/leev/ngx_http_geoip2_module"
  url "https://github.com/leev/ngx_http_geoip2_module/archive/refs/tags/3.4.tar.gz"
  sha256 "ad72fc23348d715a330994984531fab9b3606e160483236737f9a4a6957d9452"
  license "BSD-2-Clause"

  depends_on "libmaxminddb"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
