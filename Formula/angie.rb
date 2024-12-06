class Angie < Formula
  desc "HTTP(S) server and reverse proxy, and IMAP/POP3 proxy server"
  homepage "https://en.angie.software/"
  url "https://download.angie.software/files/angie-1.7.0.tar.gz"
  sha256 "0797e6e01815fdb30bbc9f703800387c9c8b2c601131a9c39509a33d73f21c01"
  license "Angie Software Product License"
  head "https://github.com/webserver-llc/angie.git", branch: "master"

  livecheck do
    url "https://en.angie.software/angie/docs/installation/sourcebuild/"
    regex(%r{https:\/\/download.angie.software\/files\/angie-([\d\.]+).tar.gz}i)
  end

  bottle do
    rebuild 1
  end

  depends_on "quictls"
  depends_on "pcre2"
  depends_on "gd"
  depends_on "geoip"

  uses_from_macos "xz" => :build
  uses_from_macos "libxcrypt"
  uses_from_macos "zlib"

  def install
    # keep clean copy of source for compiling dynamic modules e.g. passenger
    (pkgshare/"src").mkpath
    system "tar", "-cJf", (pkgshare/"src/src.tar.xz"), "."

    # Changes default port to 8080
    inreplace "conf/angie.conf" do |s|
      s.gsub! "listen       80;", "listen       8080;"
      s.gsub! "    #}\n\n}", "    #}\n    include servers/*;\n}"
    end

    quictls = Formula["quictls"]
    pcre = Formula["pcre2"]

    cc_opt = "-I#{pcre.opt_include} -I#{quictls.opt_include}"
    ld_opt = "-L#{pcre.opt_lib} -L#{quictls.opt_lib}"

    args = %W[
      --prefix=#{prefix}
      --sbin-path=#{bin}/angie
      --with-cc-opt=#{cc_opt}
      --with-ld-opt=#{ld_opt}
      --conf-path=#{etc}/angie/angie.conf
      --pid-path=#{var}/run/angie.pid
      --lock-path=#{var}/run/angie.lock
      --http-client-body-temp-path=#{var}/run/angie/client_body_temp
      --http-proxy-temp-path=#{var}/run/angie/proxy_temp
      --http-fastcgi-temp-path=#{var}/run/angie/fastcgi_temp
      --http-uwsgi-temp-path=#{var}/run/angie/uwsgi_temp
      --http-scgi-temp-path=#{var}/run/angie/scgi_temp
      --http-acme-client-path=#{var}/acme
      --http-log-path=#{var}/log/angie/access.log
      --error-log-path=#{var}/log/angie/error.log
      --with-compat
      --with-debug
      --with-http_acme_module
      --with-http_addition_module
      --with-http_auth_request_module
      --with-http_dav_module
      --with-http_degradation_module
      --with-http_flv_module
      --with-http_geoip_module
      --with-http_gunzip_module
      --with-http_gzip_static_module
      --with-http_image_filter_module
      --with-http_mp4_module
      --with-http_random_index_module
      --with-http_realip_module
      --with-http_secure_link_module
      --with-http_slice_module
      --with-http_ssl_module
      --with-http_stub_status_module
      --with-http_sub_module
      --with-http_v2_module
      --with-http_v3_module
      --with-ipv6
      --with-mail
      --with-mail_ssl_module
      --with-pcre
      --with-pcre-jit
      --with-stream
      --with-stream_geoip_module
      --with-stream_mqtt_preread_module
      --with-stream_rdp_preread_module
      --with-stream_realip_module
      --with-stream_ssl_module
      --with-stream_ssl_preread_module
    ]

    (pkgshare/"src/configure_args.txt").write args.join("\n")

    if build.head?
      system "./auto/configure", *args
    else
      system "./configure", *args
    end

    system "make", "install"
    if build.head?
      man8.install "docs/man/angie.8"
    else
      man8.install "man/angie.8"
    end
  end

  def post_install
    (etc/"angie/servers").mkpath
    (var/"run/angie").mkpath
    (var/"acme").mkpath

    # angie's docroot is #{prefix}/html, this isn't useful, so we symlink it
    # to #{HOMEBREW_PREFIX}/var/www. The reason we symlink instead of patching
    # is so the user can redirect it easily to something else if they choose.
    html = prefix/"html"
    dst = var/"www"

    if dst.exist?
      rm_r(html)
      dst.mkpath
    else
      dst.dirname.mkpath
      html.rename(dst)
    end

    prefix.install_symlink dst => "html"

    # for most of this formula's life the binary has been placed in sbin
    # and Homebrew used to suggest the user copy the plist for angie to their
    # ~/Library/LaunchAgents directory. So we need to have a symlink there
    # for such cases
    sbin.install_symlink bin/"angie" if rack.subdirs.any? { |d| d.join("sbin").directory? }
  end

  def caveats
    <<~EOS
      Docroot is: #{var}/www

      The default port has been set in #{etc}/angie/angie.conf to 8080 so that
      Angie can run without sudo.

      Angie will load all files in #{etc}/angie/servers/.

      The default directory for ACME certificates is #{var}/acme/.
    EOS
  end

  service do
    run [opt_bin/"angie", "-g", "daemon off;"]
    keep_alive false
    working_dir HOMEBREW_PREFIX
  end

  test do
    (testpath/"angie.conf").write <<~ANGIE
      worker_processes 4;
      error_log #{testpath}/error.log;
      pid #{testpath}/angie.pid;

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
          listen 8080;
          root #{testpath};
          access_log #{testpath}/access.log;
          error_log #{testpath}/error.log;
        }
      }
    ANGIE
    system bin/"angie", "-t", "-c", testpath/"angie.conf"
  end
end
