class BaidupcsGo < Formula
  desc "百度网盘客户端 - Go语言编写"
  homepage "https://github.com/iikira/BaiduPCS-Go"
  version "v3.6"
  url "https://github.com/iikira/BaiduPCS-Go/archive/#{version}.tar.gz"
  sha256 "23ff3289128b13baf3190b489f9a085f5b701491295e5be4415318475e8f3907"
  head "https://github.com/iikira/BaiduPCS-Go.git"

  depends_on "go" => :build

  def install
    ENV["GO111MODULE"] = "auto"
    ENV["GOPROXY"] = "https://goproxy.io"
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/iikira").mkpath
    ln_s buildpath, buildpath/"src/github.com/iikira/BaiduPCS-Go"
    system "go", "get", "github.com/iikira/BaiduPCS-Go"

    bin.install "bin/BaiduPCS-Go"
    bin.install_symlink "BaiduPCS-Go" => "baidupcs"
  end

  test do
    out = shell_output("#{bin}/BaiduPCS-Go --version 2>&1")
    assert_match "BaiduPCS-Go version #{version}-devel", out
    system "#{bin}/baidupcs", "--version"
    system "BaiduPCS-Go", "--version"
    system "baidupcs", "--version"
  end
end
