class StreamLuaAngieModule < Formula
  desc "Lua scripting (LuaJIT) module for the stream subsystem for angie-full"
  homepage "https://github.com/openresty/stream-lua-nginx-module"
  url "https://github.com/openresty/stream-lua-nginx-module/archive/refs/tags/v0.0.17R4.tar.gz"
  sha256 "214927614eef96d5b1f26c0adaf94a8fd8c32f73dd17e494c217ca40f60e5910"
  license "BSD-2-Clause"

  depends_on "luajit-openresty"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
