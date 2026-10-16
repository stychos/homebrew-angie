class StsAngieModule < Formula
  desc "Stream server traffic status module (HTTP part) for angie-full"
  homepage "https://github.com/vozlt/nginx-module-sts"
  url "https://github.com/vozlt/nginx-module-sts/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "0c3ec3763133e6d0d4d19bea1103f3e6576ab695c63b3c48f3e19f9d7cc29c44"
  license "BSD-2-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
