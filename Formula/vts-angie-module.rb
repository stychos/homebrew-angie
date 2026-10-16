class VtsAngieModule < Formula
  desc "Virtual host traffic status module for angie-full"
  homepage "https://github.com/vozlt/nginx-module-vts"
  url "https://github.com/vozlt/nginx-module-vts/archive/refs/tags/v0.2.7.tar.gz"
  sha256 "0003bfa57da2106367fdc3f87760910c046e7df5545db73c880fc2b80350b14c"
  license "BSD-2-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
