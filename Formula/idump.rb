class Idump < Formula
  desc "tiny image viewer for framebuffer"
  homepage "https://github.com/uobikiemukot/idump"
  version "v0.2.0"
  url "https://github.com/uobikiemukot/idump/archive/#{version}.tar.gz"
  sha256 "a1693ae61566a82c5c0c73638bc1ff7be5052823b185741f9b38a42cd71b92ac"

  def install
    system "make", "all"

    bin.install "idump"
  end

  test do
    system "idump -h"
  end
end
