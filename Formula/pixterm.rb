class Pixterm < Formula
  desc "Draw images in your ANSI terminal with true color"
  homepage "https://github.com/eliukblau/pixterm"
  version "v1.2.4"
  url "https://github.com/eliukblau/pixterm/archive/#{version}.tar.gz"
  sha256 "2529fd9ae645a28b889dfb5c5603bd797f6c07e3905d17b616532f48e03e3ba3"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/eliukblau").mkpath
    ln_s buildpath, buildpath/"src/github.com/eliukblau/pixterm"
    system "go", "get", "github.com/eliukblau/pixterm"

    bin.install "bin/pixterm"
  end

  test do
    system "pixterm", "-credits"
  end
end
