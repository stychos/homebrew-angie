class NdkAngieModule < Formula
  desc "Nginx Development Kit, needed by the lua and set-misc modules for angie-full"
  homepage "https://github.com/vision5/ngx_devel_kit"
  url "https://github.com/vision5/ngx_devel_kit/archive/refs/tags/v0.3.4.tar.gz"
  sha256 "14a28063294f645d457b1eb10e3c23bbba44398f1c5f021421b58b6f8ab31662"
  license "BSD-3-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
