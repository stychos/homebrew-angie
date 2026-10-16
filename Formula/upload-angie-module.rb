class UploadAngieModule < Formula
  desc "Multipart upload handling module for angie-full"
  homepage "https://github.com/fdintino/nginx-upload-module"
  url "https://github.com/fdintino/nginx-upload-module/archive/refs/tags/2.3.0.tar.gz"
  sha256 "c86e318addb9c88d70fdbd58ff1f6ef6f404a93070f6db8017a1f880c97946c4"
  license "BSD-2-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
