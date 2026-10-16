class DynamicLimitReqAngieModule < Formula
  desc "Dynamic request limiting module with Redis storage for angie-full"
  homepage "https://github.com/limithit/ngx_dynamic_limit_req_module"
  url "https://github.com/limithit/ngx_dynamic_limit_req_module/archive/refs/tags/1.9.3.tar.gz"
  sha256 "44d11ead8e76c5873fed4e5e231b53306771dc01a97a86be61e567f5f157b905"
  license "GPL-3.0-only"

  depends_on "hiredis"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
