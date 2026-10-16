class AngieFull < Formula
  desc "HTTP(S) server and reverse proxy with all built-in and third-party modules"
  homepage "https://en.angie.software/"
  url "https://download.en.angie.software/files/angie-1.12.4.tar.gz"
  sha256 "b236f152adb543fb6e4a94f271b873cdc0d48d570f86b1bd04435f85843f4527"
  license "BSD-2-Clause"
  head "https://github.com/webserver-llc/angie.git", branch: "master"

  livecheck do
    url "https://en.angie.software/angie/docs/installation/sourcebuild/"
    regex(%r{https://download.angie.software/files/angie-([\d.]+)\.t}i)
  end

  # Third-party modules from https://en.angie.software/angie/docs/installation/external-modules/
  # Each is available as --with-<name>-module; the sources come from the
  # <name>-angie-module formula in this tap and are compiled in statically.
  def self.third_party_modules
    {
      "auth-jwt"           => "JWT authentication (kjdev/nginx-auth-jwt)",
      "auth-ldap"          => "LDAP authentication",
      "auth-pam"           => "PAM authentication",
      "auth-spnego"        => "SPNEGO/Kerberos authentication",
      "auth-totp"          => "time-based one-time password authentication",
      "brotli"             => "Brotli compression",
      "cache-purge"        => "cache purging",
      "cgi"                => "CGI",
      "combined-upstreams" => "combined upstreams",
      "dav-ext"            => "WebDAV extensions (PROPFIND, OPTIONS, LOCK)",
      "dynamic-limit-req"  => "dynamic request limiting (Redis)",
      "echo"               => "echo/sleep/time/exec directives",
      "enhanced-memcached" => "enhanced memcached",
      "eval"               => "eval (subrequest into variable)",
      "geoip2"             => "GeoIP2 (libmaxminddb)",
      "headers-more"       => "headers-more",
      "http-auth-radius"   => "RADIUS authentication",
      "keyval"             => "key-value store (shared memory and Redis)",
      "lua"                => "Lua scripting (LuaJIT, lua-resty-core)",
      "stream-lua"         => "Lua scripting for the stream subsystem",
      "modsecurity"        => "ModSecurity v3 web application firewall",
      "njs"                => "njs JavaScript scripting",
      "ndk"                => "Nginx Development Kit",
      "oidc"               => "OpenID Connect (kjdev/nginx-oidc)",
      "postgres"           => "PostgreSQL upstream",
      "redis2"             => "Redis 2.0 protocol upstream",
      "rtmp"               => "RTMP streaming",
      "set-misc"           => "set-misc directives",
      "subs"               => "substitutions filter",
      "testcookie"         => "cookie-based DDoS protection",
      "unbrotli"           => "Brotli decompression filter",
      "unzstd"             => "Zstandard decompression filter",
      "upload"             => "multipart upload handling",
      "vod"                => "VOD on-the-fly MP4/HLS/DASH repackaging",
      "vts"                => "virtual host traffic status",
      "sts"                => "stream server traffic status (HTTP part)",
      "stream-sts"         => "stream server traffic status (stream part)",
      "zip"                => "ZIP archive streaming (mod_zip)",
      "zstd"               => "Zstandard compression",
    }
  end

  third_party_modules.each do |name, description|
    option "with-#{name}-module", "Build with the #{description} module"
    # lua is a runtime dependency (its lualib directory is baked into angie), see below
    depends_on "#{name}-angie-module" => :build if name != "lua" && build.with?("#{name}-module")
  end

  bottle do
    root_url "https://github.com/stychos/homebrew-angie/releases/download/1.12.4"
    sha256 cellar: :any, arm64_sequoia: "88a910f3ed294fda67b04b52ab11b781ccc2fad6e1c1f9754c7356ed003c4d09"
    sha256 cellar: :any, arm64_tahoe:   "b97c2efa8ea7ba967409c74b0a793aec749d7d6a477ba87a6f9d0b9143080fcd"
    sha256 cellar: :any, x86_64_linux:  "989f1a18e2aa75c2ec40ba0f0c1814bac804da7b1c74816d43bf262720828339"
  end

  depends_on "ndk-angie-module" => :build if build.with?("lua-module") || build.with?("set-misc-module")
  # Libraries linked into angie when the matching third-party module is enabled.
  # Kept as data because the option names differ from the formula names.
  def self.module_libraries
    {
      "auth-ldap"         => %w[openldap],
      "auth-spnego"       => %w[krb5],
      "brotli"            => %w[brotli],
      "dynamic-limit-req" => %w[hiredis],
      "geoip2"            => %w[libmaxminddb],
      "keyval"            => %w[hiredis],
      "lua"               => %w[lua-angie-module luajit-openresty],
      "modsecurity"       => %w[modsecurity],
      "oidc"              => %w[hiredis],
      "postgres"          => %w[libpq],
      "stream-lua"        => %w[lua-angie-module luajit-openresty],
      "unbrotli"          => %w[brotli],
      "unzstd"            => %w[zstd],
      "zstd"              => %w[zstd],
    }
  end

  needed_libraries = module_libraries.select { |name, _| build.with?("#{name}-module") }.values.flatten.uniq.sort
  needed_libraries.each { |library| depends_on library }

  depends_on "gd"
  depends_on "libxml2"
  depends_on "libxslt"
  depends_on "openssl@3"
  depends_on "pcre2"
  depends_on "gperftools" => :optional
  depends_on "perl" => :optional

  uses_from_macos "xz" => :build
  uses_from_macos "libxcrypt"
  uses_from_macos "zlib"

  conflicts_with "angie", because: "both install the angie binary and share its configuration"

  skip_clean "html"

  def install
    # keep clean copy of source for compiling dynamic modules e.g. passenger
    (pkgshare/"src").mkpath
    system "tar", "-cJf", (pkgshare/"src/src.tar.xz"), "."

    # Changes default port to 8080
    inreplace "conf/angie.conf" do |s|
      s.gsub! "listen       80;", "listen       8080;"
      s.gsub! "    #}\n\n}", "    #}\n    include servers/*;\n}"
    end

    cc_opt = %W[-I#{HOMEBREW_PREFIX}/include -I#{formula_opt_include("libxml2")}/libxml2]
    ld_opt = %W[-L#{HOMEBREW_PREFIX}/lib]
    libs = %w[libxml2 libxslt openssl@3 pcre2]
    libs << "krb5" if build.with?("auth-spnego-module")
    libs << "libpq" if build.with?("postgres-module")
    libs << "openldap" if build.with?("auth-ldap-module")
    libs.each do |name|
      cc_opt << "-I#{formula_opt_include(name)}"
      ld_opt << "-L#{formula_opt_lib(name)}"
    end

    modules = self.class.third_party_modules.keys.select { |name| build.with?("#{name}-module") }
    modules << "ndk" if modules.intersect?(%w[lua set-misc])
    # ngx_devel_kit must be configured before the modules that build on it
    ndk, others = modules.uniq.partition { |name| name == "ndk" }
    modules = ndk + others

    # Build from a private copy: some module configure scripts write into their source tree
    (buildpath/"modules").mkpath
    modules.each { |name| cp_r Formula["#{name}-angie-module"].opt_pkgshare, buildpath/"modules"/name }

    if modules.intersect?(%w[lua stream-lua])
      luajit = Formula["luajit-openresty"]
      ENV["LUAJIT_INC"] = Dir[luajit.opt_include/"luajit-*"].first
      ENV["LUAJIT_LIB"] = luajit.opt_lib.to_s
      ld_opt << "-pagezero_size 10000" << "-image_base 100000000" if OS.mac? && Hardware::CPU.intel?

      # lua-resty-core is mandatory at startup: make its location the default lua_package_path
      lualib = Formula["lua-angie-module"].opt_pkgshare/"lualib"
      defaults = "#define LUA_DEFAULT_PATH \"#{lualib}/?.lua;#{lualib}/?/init.lua\"\n" \
                 "#define LUA_DEFAULT_CPATH \"#{lualib}/?.so\"\n"
      { "lua" => "ngx_http_lua_util.c", "stream-lua" => "ngx_stream_lua_util.c" }.each do |name, file|
        next unless modules.include?(name)

        inreplace buildpath/"modules"/name/"src"/file,
                  "#if !defined(LUA_DEFAULT_PATH) && (NGX_DEBUG)",
                  "#{defaults}#if !defined(LUA_DEFAULT_PATH) && (NGX_DEBUG)"
      end
    end

    if modules.include?("brotli")
      # ngx_brotli insists on its deps/brotli submodule layout; point it at Homebrew's brotli
      deps = buildpath/"modules/brotli/deps/brotli"
      (deps/"c").mkpath
      ln_s formula_opt_include("brotli"), deps/"c/include"
      ln_s formula_opt_lib("brotli"), deps/"out"
    end
    if modules.include?("unbrotli")
      # ngx_unbrotli hardcodes /usr/local/brotli and static libraries
      inreplace buildpath/"modules/unbrotli/config" do |s|
        s.gsub! "BROTLI_DIR=/usr/local/brotli", "BROTLI_DIR=#{formula_opt_prefix("brotli")}"
        s.gsub! '"$BROTLI_DIR/lib/libbrotlidec-static.a $BROTLI_DIR/lib/libbrotlicommon-static.a"',
                '"-L$BROTLI_DIR/lib -lbrotlidec -lbrotlicommon"'
      end
    end

    if modules.include?("http-auth-radius") && OS.mac?
      # the module uses glibc's htobe16/htobe32; map them to macOS equivalents
      inreplace buildpath/"modules/http-auth-radius/src/radius_lib.c", /\A/, <<~C
        #include <libkern/OSByteOrder.h>
        #define htobe16(x) OSSwapHostToBigInt16(x)
        #define htobe32(x) OSSwapHostToBigInt32(x)
        #define be16toh(x) OSSwapBigToHostInt16(x)
        #define be32toh(x) OSSwapBigToHostInt32(x)
      C
    end

    if modules.include?("vod")
      # the module's thumbnail/volume-map code needs ffmpeg < 7: make every ffmpeg probe fail
      # so nothing from an installed ffmpeg gets linked
      inreplace buildpath/"modules/vod/config" do |s|
        s.gsub! 'ngx_feature_libs="$LIB_AV_CODEC"', 'ngx_feature_libs="-lavcodec-unavailable"'
        s.gsub! 'ngx_feature_libs="-lswscale"', 'ngx_feature_libs="-lswscale-unavailable"'
        s.gsub! 'ngx_feature_libs="$LIB_AV_FILTER"', 'ngx_feature_libs="-lavfilter-unavailable"'
      end
    end

    if modules.include?("njs")
      # njs ships its engine as a library that must be built before angie
      cd buildpath/"modules/njs" do
        system "./configure", "--no-quickjs", "--cc-opt=#{cc_opt.join(" ")}", "--ld-opt=#{ld_opt.join(" ")}"
        system "make", "libnjs"
      end
      ENV["NJS_QUICKJS"] = "NO"
    end

    ENV["NGX_KEYVAL_ZONE_REDIS"] = "1" if modules.include?("keyval")
    if modules.include?("postgres")
      # nginx 1.27+ (Angie's core) dropped default_port from the upstream server conf;
      # upstreams are matched by host and port, which the module checks just before
      inreplace buildpath/"modules/postgres/src/ngx_postgres_module.c",
                /^        if \(uscfp\[i\]->default_port && url->default_port\n.*?^        \}\n\n/m, ""
      ENV["LIBPQ_INC"] = formula_opt_include("libpq").to_s
      ENV["LIBPQ_LIB"] = formula_opt_lib("libpq").to_s
    end
    if modules.include?("modsecurity")
      ENV["MODSECURITY_INC"] = formula_opt_include("modsecurity").to_s
      ENV["MODSECURITY_LIB"] = formula_opt_lib("modsecurity").to_s
    end

    args = %W[
      --prefix=#{prefix}
      --sbin-path=#{bin}/angie
      --with-cc-opt=#{cc_opt.join(" ")}
      --with-ld-opt=#{ld_opt.join(" ")}
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
      --with-threads
      --with-pcre
      --with-pcre-jit
      --with-http_ssl_module
      --with-http_v2_module
      --with-http_v3_module
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
      --with-http_stub_status_module
      --with-http_sub_module
      --with-http_xslt_module
      --with-mail
      --with-mail_ssl_module
      --with-stream
      --with-stream_acme_module
      --with-stream_mqtt_preread_module
      --with-stream_rdp_preread_module
      --with-stream_realip_module
      --with-stream_ssl_module
      --with-stream_ssl_preread_module
    ]
    args << "--with-google_perftools_module" if build.with?("gperftools")
    if build.with?("perl")
      args << "--with-http_perl_module"
      args << "--with-perl=#{formula_opt_bin("perl")}/perl"
      args << "--with-perl_modules_path=#{lib}/perl5"
    end
    modules.each do |name|
      src = buildpath/"modules"/name
      src /= "nginx" if name == "njs"
      args << "--add-module=#{src}"
    end

    (pkgshare/"src/configure_args.txt").write args.join("\n")

    if build.head?
      system "./auto/configure", *args
    else
      system "./configure", *args
    end

    # the Perl XS module's Makefile is not parallel-safe (xsubpp runs twice for nginx.xs)
    ENV.deparallelize if build.with?("perl")
    system "make", "install"
    if build.head?
      man8.install "docs/man/angie.8"
    else
      man8.install "man/angie.8"
    end

    # Angie's docroot is #{prefix}/html, this isn't useful, so we symlink it
    # to #{HOMEBREW_PREFIX}/var/www. The reason we symlink instead of patching
    # is so the user can redirect it easily to something else if they choose.
    libexec.install prefix/"html"
    prefix.install_symlink var/"www" => "html"
  end

  post_install_steps do
    mkdir_p "{{etc}}/angie/servers"
    mkdir_p "{{var}}/run/angie"
    mkdir_p "{{var}}/acme"

    unless_path_exists "{{var}}/www" do
      move "{{libexec}}/html", "{{var}}/www"
    end
  end

  def caveats
    s = <<~EOS
      Docroot is: #{var}/www

      The default port has been set in #{etc}/angie/angie.conf to 8080 so that
      Angie can run without sudo.

      Angie will load all files in #{etc}/angie/servers/.

      The default directory for ACME certificates is #{var}/acme/.

      All built-in modules are compiled in. Third-party modules are compiled in
      statically when selected at install time, e.g.
        brew install stychos/angie/angie-full --with-brotli-module --with-headers-more-module
      See `brew options stychos/angie/angie-full` for the full list.
    EOS
    enabled = self.class.third_party_modules.keys.select { |name| build.with?("#{name}-module") }
    s += "\nThird-party modules in this build: #{enabled.join(", ")}\n" if enabled.any?
    if build.with?("lua-module") || build.with?("stream-lua-module")
      s += "\nlua-resty-core and lua-resty-lrucache are on the default lua_package_path:\n  " \
           "#{Formula["lua-angie-module"].opt_pkgshare}/lualib\n"
    end
    s
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

      stream {
        server {
          listen 8081;
          return "ok";
        }
      }
    ANGIE
    system bin/"angie", "-t", "-c", testpath/"angie.conf"
  end
end
