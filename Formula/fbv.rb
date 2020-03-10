class Fbv < Formula
  desc "A framebuffer image viewer."
  homepage "http://s-tech.elsat.net.pl/fbv/"
  version "1.0b"
  url "http://s-tech.elsat.net.pl/fbv/fbv-#{version}.tar.gz"
  sha256 "9b55b9dafd5eb01562060d860e267e309a1876e8ba5ce4d3303484b94129ab3c"

  # depends_on "cmake" => :build

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    system "./configure", "--prefix=#{prefix}"
    system "make"

    bin.install "fbv"
  end

  test do
    system "fbv -h"
  end
end
