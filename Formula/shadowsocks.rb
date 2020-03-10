class Shadowsocks < Formula
  include Language::Python::Virtualenv

  desc "Shadowsocks Python version"
  homepage "https://github.com/shadowsocks/shadowsocks"
  version "2.9.1"
  url "https://github.com/shadowsocks/shadowsocks/archive/#{version}.tar.gz"
  sha256 "122df903f95a1117fc2b4738c5017517a15bf2428dc714c45ce3537ecce4a576"

  depends_on "python"

  def install
    virtualenv_install_with_resources
  end

  test do
    # server test
    system "ssserver -h"
    ver_s = shell_output("#{bin}/ssserver --version")
    assert_match "Shadowsocks #{version}", ver_s
    # client test
    system "sslocal -h"
    ver_c = shell_output("#{bin}/sslocal --version")
    assert_match "Shadowsocks #{version}", ver_c
  end
end
