class Angie < Formula
  desc "HTTP(S) server and reverse proxy, and IMAP/POP3 proxy server"
  homepage "https://en.angie.software/"
  url "https://download.angie.software/files/angie-1.11.3.tar.gz"
  sha256 "08fa99d18a90f738674b300f64867406045ad5c518e952cd24e3ffdb0c14117d"
  license "BSD-2-Clause"
  head "https://github.com/webserver-llc/angie.git", branch: "master"

  livecheck do
    url "https://en.angie.software/angie/docs/installation/sourcebuild/"
    regex(%r{https://download.angie.software/files/angie-([\d.]+)\.t}i)
  end

  bottle do
    root_url "https://github.com/stychos/homebrew-angie/releases/download/bottle-6e20fd9"
    sha256 cellar: :any, arm64_sequoia: "c9f15950d81f8fb8dd5c413278a399f63911649abafc35c6f3f24ff999965563"
    sha256 cellar: :any, arm64_sonoma:  "a102e2a2d3b28e269c4f17b0d2146a523aacc897ef73ce1e7b7eb8fa999ebc9c"
    sha256 cellar: :any, arm64_tahoe:   "e5c82a9e8d9322601723e9b162520b5b1ada6f28757ff30e20b6d2d27fe9d41a"
    sha256 cellar: :any, sequoia:       "cede26e8ae54815cf8d7b826dfafe084f92b2b9a48fd57fb47500e616de026d3"
    sha256 cellar: :any, x86_64_linux:  "d8fe6189f1de372f8cd74517b47041727f8bff27c9bc6922b53ee6acab8e7ab1"
  end

  bottle do
    root_url "https://github.com/stychos/homebrew-angie/releases/download/1.11.3"
    sha256 cellar: :any, arm64_sequoia: "0f7a3e67ababd88259b88bc2cfbe5165398e36c7cb4863ee8636e5c157a43390"
    sha256 cellar: :any, arm64_sonoma:  "30076d2aaf68bf8b5d3d56abd7f36c1d046ceaaea8ba42716717eb6ed09f391a"
    sha256 cellar: :any, arm64_tahoe:   "51a858fcf993cfee61ba843029939b1370dae21d42c5c3cb595b201531295619"
    sha256 cellar: :any, sequoia:       "e00e890574d5e6121644de0583d4867ed3ee450fbba31dfb2b186d293d3675c0"
    sha256 cellar: :any, x86_64_linux:  "f501a9493d8836aa40b08b08ed22d1eccc77197ae493779879ecf37fbd391464"
  end

  depends_on "gd"
  depends_on "openssl@3"
  depends_on "pcre2"

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

    openssl = Formula["openssl@3"]
    pcre = Formula["pcre2"]

    cc_opt = "-I#{pcre.opt_include} -I#{openssl.opt_include}"
    ld_opt = "-L#{pcre.opt_lib} -L#{openssl.opt_lib}"

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

    # Angie's docroot is #{prefix}/html, this isn't useful, so we symlink it
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
    # and Homebrew used to suggest the user copy the plist for Angie to their
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
