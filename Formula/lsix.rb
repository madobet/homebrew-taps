class Lsix < Formula
  desc "Like \"ls\", but for images. Shows thumbnails in terminal using sixel graphics."
  homepage "https://github.com/hackerb9/lsix"
  version "1.6.2"
  url "https://github.com/hackerb9/lsix/archive/#{version}.tar.gz"
  sha256 "e0f4e51b75d677621de9182971c8d2103ce08caafef28b9b930536a5d2bdaaac"

  #depends_on "libsixel" => :optional

  def install
    bin.install "lsix"
  end

  test do
    system "false"
  end
end
