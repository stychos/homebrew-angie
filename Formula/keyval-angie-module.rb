class KeyvalAngieModule < Formula
  desc "Key-value store module with shared memory and Redis for angie-full"
  homepage "https://github.com/kjdev/nginx-keyval"
  url "https://github.com/kjdev/nginx-keyval/archive/refs/tags/0.5.0.tar.gz"
  sha256 "893b59f121a959ddc84f8d26562cdcf9c63605c1e441b41ae01da37e28168f86"
  license "MIT"

  depends_on "hiredis"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
