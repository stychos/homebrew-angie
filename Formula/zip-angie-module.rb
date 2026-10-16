class ZipAngieModule < Formula
  desc "ZIP archive streaming module (mod_zip) for angie-full"
  homepage "https://github.com/evanmiller/mod_zip"
  url "https://github.com/evanmiller/mod_zip/archive/refs/tags/1.3.0.tar.gz"
  sha256 "5e7f24b6b4efb8258d92ec921ade9df69e4bad36f833a39b47ee947b3d637f22"
  license "BSD-3-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
