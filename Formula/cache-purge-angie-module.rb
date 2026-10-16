class CachePurgeAngieModule < Formula
  desc "Cache purging module for angie-full"
  homepage "https://github.com/nginx-modules/ngx_cache_purge"
  url "https://github.com/nginx-modules/ngx_cache_purge/archive/refs/tags/3.0.4.tar.gz"
  sha256 "d9eefad55c1306af5a9d22d75743240ffb6c6351152c6893fa6144867d7f9087"
  license "BSD-2-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
