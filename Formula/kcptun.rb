class Kcptun < Formula
  desc "A Stable & Secure Tunnel based on KCP with N:M multiplexing and FEC. Available for ARM, MIPS, 386 and AMD64"
  homepage "https://github.com/xtaci/kcptun"
  version "v20190924"
  url "https://github.com/xtaci/kcptun/archive/#{version}.tar.gz"
  sha256 "40d24575b1604bb046f713aebed4f722990b8b2e245f1ad385fb51df956d3a24"

  depends_on "go" => :build

  def install
    ENV["GO111MODULE"] = "auto"
    ENV["GOPROXY"] = "https://goproxy.io"
    system "go", "build", "-o", "bin/kcptunc", "./client"
    system "go", "build", "-o", "bin/kcptuns", "./server"

    bin.install "bin/kcptunc"
    bin.install "bin/kcptuns"
  end

  test do
    ver_c = shell_output("#{bin}/kcptunc -v")
    assert_match "kcptun version SELFBUILD", ver_c
    ver_s = shell_output("#{bin}/kcptuns -v")
    assert_match "kcptun version SELFBUILD", ver_s
    system "kcptunc", "-v"
    system "kcptuns", "-v"
  end
end
