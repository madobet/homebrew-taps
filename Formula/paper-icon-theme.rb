class PaperIconTheme < Formula
  desc "Paper Icon Theme"
  homepage "http://snwh.org/paper"
  version "v.1.5.0"
  url "https://github.com/snwh/paper-icon-theme/archive/#{version}.tar.gz"
  sha256 "62f21dfe95ece481e5c635480f32347f1ad27ea66b2ef0526fe799090b298ece"

  depends_on "meson" => :build
  # meson depends on ninja, so there is no need to use
  # depends_on "ninja" => :build

  def install
    system "meson", "\"build\"", "--prefix=#{prefix}"
    system "ninja", "-C", "\"build\"", "install"
  end

  test do
    system "false"
  end
end
