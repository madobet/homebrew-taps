# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Fim < Formula
  desc "FIM: Fbi IMproved"
  homepage "https://www.nongnu.org/fbi-improved/"
  url "https://bigsearcher.com/mirrors/nongnu/fbi-improved/fim-0.6-trunk.tar.bz2"
  sha256 "b2b24ee1eca4cc573a83d30bb0f7b2aad4a88c693f30aeceac4642c5f756fc89"

  depends_on "sdl" => :build
  depends_on "imlib2" => :build
  depends_on "aalib" => :build

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure
    # system "./configure", "--prefix=#{prefix}"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    # system "make install"
    
    bin.install "fim"
  end

  test do
    system "fim --version"
  end
end
