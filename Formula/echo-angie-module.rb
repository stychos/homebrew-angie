class EchoAngieModule < Formula
  desc "Echo, sleep, time and exec directives module for angie-full"
  homepage "https://github.com/openresty/echo-nginx-module"
  url "https://github.com/openresty/echo-nginx-module/archive/refs/tags/v0.65.tar.gz"
  sha256 "448393d4da20a14922c424d575ecc274990cd02e9882efa24b52ed40cc1a50af"
  license "BSD-2-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
