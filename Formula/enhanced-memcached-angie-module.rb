class EnhancedMemcachedAngieModule < Formula
  desc "Enhanced memcached module for angie-full"
  homepage "https://github.com/bpaquet/ngx_http_enhanced_memcached_module"
  url "https://github.com/bpaquet/ngx_http_enhanced_memcached_module/archive/refs/tags/v0.3.tar.gz"
  sha256 "4071b2cc0baa9f403c124c0ef0cdfbde14dacc1ec9f0dbc92d7310ac530e3eeb"
  license "Apache-2.0"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
