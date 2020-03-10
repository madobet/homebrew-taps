class Udp2rawTunnel < Formula
  desc "A Tunnel which Turns UDP Traffic into Encrypted UDP/FakeTCP/ICMP Traffic by using Raw Socket,helps you Bypass UDP FireWalls(or Unstable UDP Environment)"
  homepage "https://github.com/wangyu-/udp2raw-tunnel"
  version "20181113.0"
  url "https://github.com/wangyu-/udp2raw-tunnel/archive/#{version}.tar.gz"
  sha256 "32883a6ee1b2d9e9587cbe0abfdeb6fb6aa8a7f576f0848fd31aff5f965be72d"

  def install
    system "make"
    bin.install "udp2raw"

    (buildpath/"udp2raw_script.sh").write <<~EOS
    #!/bin/bash
    CONF_FILE="$1"
    TARGET="$2"
    RULE=$($(command -v su) -s $(command -v bash) nobody -c "#{HOMEBREW_PREFIX}/bin/udp2raw -g --conf-file $CONF_FILE")

    if [[ "$RULE" =~ ^(.*?)iptables\\ \\-I\\ (.*?)\\ \\-j\\ DROP(.*?)$ ]]; then
      RULE="${BASH_REMATCH[2]}"
    else
      echo "Malformed output"
      exit 1
    fi

    if [[ "$TARGET" == 'insert' ]]; then
      $(command -v iptables) -I $RULE -j DROP || exit 1
    elif [[ "$TARGET" == 'delete' ]]; then
      $(command -v iptables) -D $RULE -j DROP || exit 1
    fi
    EOS
    bin.install "udp2raw_script.sh"

    (buildpath/"udp2raw_systemd").write <<~EOS
    #!/bin/sh
    directive=${1}
    case ${directive} in
    install|deploy)
      sudo cp -f #{etc}/udp2raw/udp2raw@.service.template /etc/systemd/system/udp2raw@.service
      sudo systemctl daemon-reload
    ;;
    remove|uninstall)
      sudo systemctl disable $(systemctl --no-legend|grep -E 'udp2raw.*\\.service'|awk '{print $1}')
      sudo systemctl stop $(systemctl --no-legend|grep -E 'udp2raw.*\\.service'|awk '{print $1}')
      sudo rm -f /etc/systemd/system/udp2raw@.service
      sudo systemctl daemon-reload
    ;;
    help|*)
      printf '
      Usage: udp2raw_systemd [directive]

      directive:
        install|deploy      Deploy the systemd service of udp2raw
        remove|uninstall    Remove the systemd service of udp2raw
      '
    ;;
    esac
    EOS
    bin.install "udp2raw_systemd"
  end

  def post_install
    system "rm", "-f", "#{etc}/udp2raw/udp2raw@.service.template"
    (etc/"udp2raw/udp2raw@.service.template").write <<~EOS
    [Unit]
    Description=UDP over TCP/ICMP/UDP tunnel
    Documentation=https://github.com/wangyu-/udp2raw-tunnel/blob/master/doc/README.zh-cn.md
    After=network-online.target
    
    [Service]
    User=nobody
    Type=simple
    PermissionsStartOnly=true
    CapabilityBoundingSet=CAP_NET_RAW CAP_NET_ADMIN
    ExecStartPre=#{HOMEBREW_PREFIX}/bin/udp2raw_script.sh #{etc}/udp2raw/%i.conf insert
    ExecStart=#{HOMEBREW_PREFIX}/bin/udp2raw --conf-file #{etc}/udp2raw/%i.conf
    ExecStopPost=#{HOMEBREW_PREFIX}/bin/udp2raw_script.sh #{etc}/udp2raw/%i.conf delete
    Restart=always
    RestartSec=30
    StartLimitBurst=10
    
    [Install]
    WantedBy=multi-user.target
    EOS
  end

  test do
    system "udp2raw -h"
  end
end
