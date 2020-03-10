class Udpspeeder < Formula
  desc "A Tunnel which Improves your Network Quality on a High-latency Lossy Link by using Forward Error Correction,for All Traffics(TCP/UDP/ICMP)"
  homepage "https://github.com/wangyu-/UDPspeeder"
  version "20190121.0"
  url "https://github.com/wangyu-/UDPspeeder/archive/#{version}.tar.gz"
  sha256 "3b232a5dac09bc44b37e702ae090f1e478fbc25e2c930e45766031c975ae43c5"

  def install
    system "make"
    bin.install "speederv2"
  end

  test do
    system "speederv2 -h"
  end
end
