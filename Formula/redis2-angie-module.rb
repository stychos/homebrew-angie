class Redis2AngieModule < Formula
  desc "Redis 2.0 protocol upstream module for angie-full"
  homepage "https://github.com/openresty/redis2-nginx-module"
  url "https://github.com/openresty/redis2-nginx-module/archive/refs/tags/v0.15.tar.gz"
  sha256 "d255571bcfb9939b78099df39cb4d42f174d789aec8c8e5e47b93942b0299438"
  license "BSD-2-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
