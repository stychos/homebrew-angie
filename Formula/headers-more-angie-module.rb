class HeadersMoreAngieModule < Formula
  desc "Set, add and clear arbitrary headers module for angie-full"
  homepage "https://github.com/openresty/headers-more-nginx-module"
  url "https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v0.40.tar.gz"
  sha256 "c14cb5e6c998590c209efbf77bd7637ce2cab02332e4192756a8af5b26ba4284"
  license "BSD-2-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
