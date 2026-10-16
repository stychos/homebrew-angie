class LuaAngieModule < Formula
  desc "Lua scripting (LuaJIT) module with lua-resty-core for angie-full"
  homepage "https://github.com/openresty/lua-nginx-module"
  url "https://github.com/openresty/lua-nginx-module/archive/refs/tags/v0.10.31.tar.gz"
  sha256 "123d8203e74bf66f71437c7b3fa070bf8d24e6d332981bc18dc2db43303cc741"
  license "BSD-2-Clause"

  depends_on "luajit-openresty"
  depends_on "ndk-angie-module"

  resource "lua-resty-core" do
    url "https://github.com/openresty/lua-resty-core/archive/refs/tags/v0.1.34rc3.tar.gz"
    sha256 "28848c6c9f8878b8cbfc398b3774fdd0cb172401ca1798441bfb1689ac0210fb"
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
