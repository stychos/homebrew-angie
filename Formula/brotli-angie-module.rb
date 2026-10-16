class BrotliAngieModule < Formula
  desc "Brotli compression module (google/ngx_brotli) for angie-full"
  homepage "https://github.com/google/ngx_brotli"
  url "https://github.com/google/ngx_brotli/archive/a71f9312c2deb28875acc7bacfdd5695a111aa53.tar.gz"
  version "2023.10.09"
  sha256 "1d21be34f3b7b6d05a8142945e59b3a47665edcdfe0f3ee3d3dbef121f90c08c"
  license "BSD-2-Clause"

  livecheck do
    skip "Upstream's only tag (v1.0.0rc) predates the pinned commit"
  end

  depends_on "brotli"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
