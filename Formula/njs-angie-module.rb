class NjsAngieModule < Formula
  desc "JavaScript scripting (njs) module for angie-full"
  homepage "https://github.com/nginx/njs"
  url "https://github.com/nginx/njs/archive/refs/tags/1.0.2.tar.gz"
  sha256 "84a114499fa6878d3ec52b99c1cf2874a91eb0d915408f418a2b1279519f09ae"
  license "BSD-2-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"nginx/config"
  end
end
