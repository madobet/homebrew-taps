class Enginx < Formula
  desc "A fork of nginx with external modules"
  homepage "https://nginx.org/"
  # Use "mainline" releases only (odd minor version number), not "stable"
  # See https://www.nginx.com/blog/nginx-1-12-1-13-released/ for why
  url "https://nginx.org/download/nginx-1.17.3.tar.gz"
  sha256 "3b84fe1c2cf9ca22fde370e486a9ab16b6427df1b6ea62cdb61978c9f34d0f3c"
  revision 1
  head "https://hg.nginx.org/nginx/", :using => :hg

  # todo: make my own bottle
  #bottle do
  #  sha256 "484511b8e595f7dba53248439c320208fc4b885ba0baf78e05cbb7f89e80b755" => :catalina
  #  sha256 "11b43209912c3f75918d07a36c9e676ad042707a2f2948115edc3242daf0b28d" => :mojave
  #  sha256 "fb7d0e09b9fa42615cb53f03c2ddaad90946a79e9bf184d48f430b7f9ce1513e" => :high_sierra
  #  sha256 "61f78dccbe4df891bf0697ac906e6fe779ca2b3a61ab70b28412439c419d91a7" => :sierra
  #  sha256 "be420cf10af308d7c17046400770232c006aa7395454fce6733748d6c66306d6" => :x86_64_linux
  #end

  # Mandatory requirements:
  # 1. OpenSSL library version between 1.0.2 - 1.1.1
  #    or LibreSSL library
  #    or BoringSSL library
  # NOTE: ENGINX can also be compiled against LibreSSL andBoringSSL crypto libraries instead of OpenSSL.
  # 2. Zlib library version between 1.1.3 - 1.2.11
  # 3. PCRE library version between 4.4 - 8.42
  depends_on "openssl@1.1"
  depends_on "pcre"
  depends_on "xz" => :build unless OS.mac? # for the tar command in the install step
  depends_on "zlib"

  # Optional requirements:
  # 1. Perl
  # 2. LibGD for HTTP image filter module
  # 3. MaxMind GeoIP Legacy C Library
  # 4. libxml2 for build and runhttp_xslt_module
  # 5. libxslt for build and run http_xslt_module
  depends_on "perl"
  depends_on "libgd"
  depends_on "geoip"
  depends_on "libxml2"
  depends_on "libxslt"

  # Optional installation:
  # It is recommended to install socat first.
  # We use socat for standalone server if you use standalone mode.
  # If you don't use standalone mode, just ignore this warning.
  # This module will insert script piece into different scripts
  depends_on "socat" => :recommended

  def install
    # keep clean copy of source for compiling dynamic modules e.g. passenger
    (pkgshare/"src").mkpath
    system "tar", "-cJf", (pkgshare/"src/src.tar.xz"), *("--options" if OS.mac?), *("compression-level=9" if OS.mac?), "."

    # Changes default port to 9120
    inreplace "conf/nginx.conf" do |s|
      s.gsub! "#user  nobody;", "#user  enginx;"
      s.gsub! "listen       80;", "listen       9120;"
      s.gsub! "    #}\n\n}", "    #}\n    include sers/*;\n}"
    end

    openssl = Formula["openssl@1.1"]
    pcre = Formula["pcre"]
    zlib = Formula["zlib"]

    perl = Formula["perl"]
    libgd = Formula["libgd"]
    libgeoip = Formula["geoip"]
    libxml2 = Formula["libxml2"]
    libxslt = Formula["libxslt"]

    #cc_opt = "-I#{pcre.opt_include} -I#{openssl.opt_include}"
    cc_opt = "-I#{pcre.opt_include} -I#{openssl.opt_include} -I#{zlib.opt_include} -I#{perl.opt_include} -I#{libgd.opt_include} -I#{libgeoip.opt_include} -I#{libxml2.opt_include} -I#{libxslt.opt_include} -O2"
    #ld_opt = "-L#{pcre.opt_lib} -L#{openssl.opt_lib}"
    ld_opt = "-L#{pcre.opt_lib} -L#{openssl.opt_lib} -L#{zlib.opt_lib} -L#{perl.opt_lib} -L#{libgd.opt_lib} -L#{libgeoip.opt_lib} -L#{libxml2.opt_lib} -L#{libxslt.opt_lib}"

    args = %W[
      --prefix=#{prefix}
      --sbin-path=#{bin}/enginx
      --user=enginx
      --group=enginx
      --build=madobet@outlook.com
      --with-cc-opt=#{cc_opt}
      --with-ld-opt=#{ld_opt}
      --conf-path=#{etc}/enginx/enginx.conf
      --pid-path=#{var}/run/enginx.pid
      --lock-path=#{var}/run/enginx.lock
      --http-client-body-temp-path=#{var}/run/enginx/client_body_temp
      --http-proxy-temp-path=#{var}/run/enginx/proxy_temp
      --http-fastcgi-temp-path=#{var}/run/enginx/fastcgi_temp
      --http-uwsgi-temp-path=#{var}/run/enginx/uwsgi_temp
      --http-scgi-temp-path=#{var}/run/enginx/scgi_temp
      --http-log-path=#{var}/log/enginx/access.log
      --error-log-path=#{var}/log/enginx/error.log
      --with-threads
      --with-file-aio
      --with-compat
      --with-debug
      --with-http_addition_module
      --with-http_image_filter_module
      --with-http_geoip_module
      --with-http_auth_request_module
      --with-http_dav_module
      --with-http_degradation_module
      --with-http_flv_module
      --with-http_gunzip_module
      --with-http_gzip_static_module
      --with-http_mp4_module
      --with-http_random_index_module
      --with-http_realip_module
      --with-http_secure_link_module
      --with-http_slice_module
      --with-http_ssl_module
      --with-http_stub_status_module
      --with-http_sub_module
      --with-http_v2_module
      --with-ipv6
      --with-mail
      --with-mail_ssl_module
      --with-pcre
      --with-pcre-jit
      --with-stream
      --with-stream_realip_module
      --with-stream_ssl_module
      --with-stream_ssl_preread_module
      --add-module=#{buildpath}/ngx_http_substitutions_filter_module
      --add-dynamic-module=#{buildpath}/ngx_http_google_filter_module
    ]

    (pkgshare/"src/configure_args.txt").write args.join("\n")

    system "git", "-C", "#{buildpath}", "clone", "git://github.com/yaoweibin/ngx_http_substitutions_filter_module.git"
    system "git", "-C", "#{buildpath}", "clone", "https://github.com/cuber/ngx_http_google_filter_module"

    if build.head?
      system "./auto/configure", *args
    else
      system "./configure", *args
    end

    system "make", "install"
    if build.head?
      man8.install "docs/man/nginx.8"
    else
      man8.install "man/nginx.8"
    end

    (buildpath/"enginx_systemd").write <<~EOS
    #!/bin/sh
    directive=${1}
    case ${directive} in
    install|deploy)
      ! cat /etc/passwd | grep enginx && sudo useradd -M -U -s /sbin/nologin enginx
      ! cat /etc/group | grep ${USER} | grep enginx && sudo usermod -a -G enginx ${USER}
      sudo chown -R ${USER}:enginx #{var}/enginx
      sudo find #{var}/enginx -type d -exec chmod u=rwX,g=rwXs,o=rX {} \\;
      sudo find #{var}/enginx -type f -exec chmod u=rwX,g=rwX,o=rX {} \\;
      sudo chown -R ${USER}:enginx #{etc}/enginx
      sudo find #{etc}/enginx -type d -exec chmod u=rwX,g=rwXs,o=rX {} \\;
      sudo find #{etc}/enginx -type f -exec chmod u=rwX,g=rwX,o=rX {} \\;
      sed -E "s/^.*User=.*$/User=${USER}/g" #{etc}/enginx/enginx.service.template > #{etc}/enginx/enginx.service
      sed -i -E "s/^.*Group=.*$/Group=${USER}/g" #{etc}/enginx/enginx.service
      sudo cp -f #{etc}/enginx/enginx.service /etc/systemd/system/enginx.service
      sudo systemctl daemon-reload
    ;;
    remove|uninstall)
      cat /etc/group | grep ${USER} | grep enginx && sudo gpasswd -d ${USER} enginx
      cat /etc/passwd | grep enginx && sudo userdel -r enginx
      cat /etc/group | grep enginx && sudo groupdel -f enginx
      sudo chown -R ${USER}:${USER} #{var}/enginx
      sudo find #{var}/enginx -type d -exec chmod u=rwX,g=rwXs,o=rX {} \\;
      sudo find #{var}/enginx -type f -exec chmod u=rwX,g=rwX,o=rX {} \\;
      sudo chown -R ${USER}:${USER} #{etc}/enginx
      sudo find #{etc}/enginx -type d -exec chmod u=rwX,g=rwXs,o=rX {} \\;
      sudo find #{etc}/enginx -type f -exec chmod u=rwX,g=rwX,o=rX {} \\;
      sudo systemctl disable $(systemctl --no-legend|grep -E 'enginx.*\.service'|awk '{ print $1}')
      sudo systemctl stop $(systemctl --no-legend|grep -E 'enginx.*\.service'|awk '{ print $1}')
      rm -f #{etc}/enginx/enginx.service
      sudo rm -f /etc/systemd/system/enginx.service
      sudo systemctl daemon-reload
    ;;
    help|*)
      printf '\
      Usage: enginx_systemd [directive]

      directive:
        install|deploy      Deploy the systemd service of enginx
        remove|uninstall    Remove the systemd service of enginx
      '
    ;;
    esac
    EOS
    bin.install "enginx_systemd"
  end

  def post_install
    (etc/"enginx/sers").mkpath
    (var/"run/enginx").mkpath

    # enginx's docroot is #{prefix}/html, this isn't useful, so we symlink it
    # to #{HOMEBREW_PREFIX}/var/enginx/www. The reason we symlink instead of patching
    # is so the user can redirect it easily to something else if they choose.
    html = prefix/"html"
    dst = var/"enginx/www"

    if dst.exist?
      html.rmtree
      dst.mkpath
    else
      dst.dirname.mkpath
      html.rename(dst)
    end

    prefix.install_symlink dst => "html"

    # for most of this formula's life the binary has been placed in sbin
    # and Homebrew used to suggest the user copy the plist for enginx to their
    # ~/Library/LaunchAgents directory. So we need to have a symlink there
    # for such cases
    if rack.subdirs.any? { |d| d.join("sbin").directory? }
      sbin.install_symlink bin/"enginx"
    end

    # systemd service file
    system "rm", "-f", "#{etc}/enginx/enginx.service.template"
    (etc/"enginx/enginx.service.template").write <<~EOS
      [Unit]
      Description=A fork of nginx with external modules compiled by madobet
      After=network.target network-online.target nss-lookup.target

      [Service]
      # replace with your info this two lines bellow
      User=YOUR_USER_NAME
      Group=YOUR_USER_GROUP
      Type=forking
      PIDFile=#{var}/run/enginx.pid
      PrivateDevices=yes
      SyslogLevel=err
      WorkingDirectory=#{etc}/enginx

      ExecStart=#{HOMEBREW_PREFIX}/bin/enginx -g 'pid #{var}/run/enginx.pid; error_log stderr;'
      ExecReload=#{HOMEBREW_PREFIX}/bin/enginx -s reload
      Restart=on-failure
      RestartSec=5s
      KillMode=mixed

      CapabilityBoundingSet=CAP_NET_BIND_SERVICE
      AmbientCapabilities=CAP_NET_BIND_SERVICE
      NoNewPrivileges=true
      ProtectSystem=full
      DeviceAllow=/dev/null rw
      DeviceAllow=/dev/net/tun rw

      [Install]
      WantedBy=multi-user.target
    EOS

  end

  def caveats
    <<~EOS
      Docroot is: #{var}/enginx/www

      The default port has been set in #{etc}/enginx/enginx.conf to 9120 so that enginx can run without sudo.

      enginx will load all files in #{etc}/enginx/sers/.

      There is a systemd service file template produced: #{etc}/enginx/enginx.service.template
      Deploy systemd service by:

      $ enginx_systemd install

      Simply type

      $ enginx_systemd remove

      to remove all systemd service and related account enginx:enginx

      The socat package is installed as recommended but not necessary, so if there is something wrong while installation, try:

      $ brew reinstall enginx --without-socat
    EOS
  end

  plist_options :manual => "enginx"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/enginx</string>
            <string>-g</string>
            <string>daemon off;</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
  EOS
  end

  test do
    (testpath/"enginx.conf").write <<~EOS
      worker_processes 4;
      error_log #{testpath}/error.log;
      pid #{testpath}/enginx.pid;

      events {
        worker_connections 1024;
      }

      http {
        client_body_temp_path #{testpath}/client_body_temp;
        fastcgi_temp_path #{testpath}/fastcgi_temp;
        proxy_temp_path #{testpath}/proxy_temp;
        scgi_temp_path #{testpath}/scgi_temp;
        uwsgi_temp_path #{testpath}/uwsgi_temp;

        server {
          listen 9120;
          root #{testpath};
          access_log #{testpath}/access.log;
          error_log #{testpath}/error.log;
        }
      }
    EOS
    system bin/"enginx", "-t", "-c", testpath/"enginx.conf"
  end
end
