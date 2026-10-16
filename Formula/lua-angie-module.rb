class LuaAngieModule < Formula
  desc "Lua scripting (LuaJIT) module with lua-resty-core for angie-full"
  homepage "https://github.com/openresty/lua-nginx-module"
  url "https://github.com/openresty/lua-nginx-module/archive/refs/tags/v0.10.29R2.tar.gz"
  sha256 "2435bb65900d556a9175c77548ff0ef4cb507b786f57f7d1c4a7904a7f5063fd"
  license "BSD-2-Clause"

  depends_on "luajit-openresty"
  depends_on "ndk-angie-module"

  resource "lua-resty-core" do
    url "https://github.com/openresty/lua-resty-core/archive/refs/tags/v0.1.32R1.tar.gz"
    sha256 "7d36188261f44d489acc1671ced73207e2f7adba70663d3f32804509873f3370"
  end

  resource "lua-resty-lrucache" do
    url "https://github.com/openresty/lua-resty-lrucache/archive/refs/tags/v0.15.tar.gz"
    sha256 "8cf1a22e0d5b8f35cb0b2e14c58fcb3aa505a8fb6e956817f0cdb1f06593f072"
  end

  def install
    pkgshare.install Dir["*"]
    # Lua libraries that ngx_lua loads at startup; angie-full bakes this path into the module
    (pkgshare/"lualib").mkpath
    resources.each { |r| r.stage { cp_r Dir["lib/*"], pkgshare/"lualib" } }
  end

  test do
    assert_path_exists pkgshare/"config"
    assert_path_exists pkgshare/"lualib/resty/core.lua"
  end
end
