class EvalAngieModule < Formula
  desc "Eval module (evaluate a subrequest into a variable) for angie-full"
  homepage "https://github.com/openresty/nginx-eval-module"
  url "https://github.com/openresty/nginx-eval-module/archive/refs/tags/2016.06.10.tar.gz"
  sha256 "6b91d3c2c2f254ebb37eb3dd6dd41048dfb18320bb98a3afdd1ad38b47f6d609"
  license "BSD-2-Clause"

  def install
    pkgshare.install Dir["*"]
  end

  test do
    assert_path_exists pkgshare/"config"
  end
end
