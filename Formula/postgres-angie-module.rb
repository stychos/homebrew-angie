class PostgresAngieModule < Formula
  desc "PostgreSQL upstream module for angie-full"
  homepage "https://github.com/FRiCKLE/ngx_postgres"
  url "https://github.com/FRiCKLE/ngx_postgres/archive/refs/tags/1.0rc7.tar.gz"
  sha256 "c942e674a7273ab87caab4dcad626ab54852be192c29b1add50d2cb535e3cbb9"
  license "BSD-2-Clause"

  depends_on "libpq"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
