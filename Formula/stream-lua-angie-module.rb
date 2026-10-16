class StreamLuaAngieModule < Formula
  desc "Lua scripting (LuaJIT) module for the stream subsystem for angie-full"
  homepage "https://github.com/openresty/stream-lua-nginx-module"
  url "https://github.com/openresty/stream-lua-nginx-module/archive/refs/tags/v0.0.19rc4.tar.gz"
  sha256 "1d4c9d1febf8a31d883f8bf4658e82bd0b39d693f1b4e4de59282e6377d31eec"
  license "BSD-2-Clause"

  livecheck do
    skip "Bumped together with lua-angie-module to the versions of the latest OpenResty release (see CLAUDE.md)"
  end

  depends_on "luajit-openresty"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
