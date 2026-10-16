class UnbrotliAngieModule < Formula
  desc "Brotli decompression filter module for angie-full"
  homepage "https://github.com/clyfish/ngx_unbrotli"
  url "https://github.com/clyfish/ngx_unbrotli/archive/60bed634504967a323645f8f53566cca3f2c3f53.tar.gz"
  version "2023.06.01"
  sha256 "5ff66c1ab88824b81b65e8ef876a68bfbee79d4a1b1c91eae628db24252e796d"

  livecheck do
    skip "Upstream has no tagged releases; pinned to a commit"
  end

  depends_on "brotli"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
