class SetMiscAngieModule < Formula
  desc "Various set_xxx directives (set-misc) module for angie-full"
  homepage "https://github.com/openresty/set-misc-nginx-module"
  url "https://github.com/openresty/set-misc-nginx-module/archive/refs/tags/v0.34.tar.gz"
  sha256 "f083e6a68520a9dfa09f0afbeb88ab7539f479cc5af91d8607ae2ab1874f9898"
  license "BSD-2-Clause"

  depends_on "ndk-angie-module"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
