class Yaft < Formula
  desc "yet another framebuffer terminal"
  homepage "https://github.com/uobikiemukot/yaft"
  version "v0.2.9"
  url "https://github.com/uobikiemukot/yaft/archive/#{version}.tar.gz"
  sha256 "80f7e6937ff0a34f77859c684d6f8e23c55d696e0bac4ac8b2f11f785db0374c"

  def install
    system "export" "LANG=en_US.UTF-8"
    system "make"

    bin.install "yaft"
  end

  test do
    system "yaft -h"
  end
end
