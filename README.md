# Angie Homebrew tap

[Angie](https://en.angie.software/) is an efficient, powerful and scalable web server, forked from nginx by some of its former core developers.

```shell
brew tap stychos/angie
brew trust --tap stychos/angie   # Homebrew 7+ only loads third-party taps you have trusted
```

## Two builds

| Formula | What you get | Bottles |
|---|---|---|
| `angie` | Minimal: Angie's default modules plus SSL, HTTP/2, HTTP/3, ACME, realip, stub_status and gzip_static | yes |
| `angie-full` | Every built-in module (stream, mail, WebDAV, image filter, XSLT, slice, sub, mp4, flv, ...) plus optional third-party modules | yes, when installed without options |

```shell
brew install stychos/angie/angie                      # minimal, from bottle
brew install stychos/angie/angie-full                 # all built-in modules, from bottle
brew install stychos/angie/angie-full --with-brotli-module --with-headers-more-module
brew install stychos/angie/angie-full --with-lua-module --with-njs-module --with-vts-module
brew options stychos/angie/angie-full                 # every --with-... option
brew services start stychos/angie/angie-full          # run it (port 8080)
```

The two formulae conflict with each other (same `angie` binary and `/opt/homebrew/etc/angie`); switch with `brew uninstall angie && brew install stychos/angie/angie-full`. Any `--with-...` option means a build from source, as everywhere in Homebrew. `--with-perl` and `--with-gperftools` add the built-in Perl and Google perftools modules.

The default port is 8080 so Angie runs without sudo. Configuration lives in `/opt/homebrew/etc/angie/` (`servers/*` is included), the docroot is `/opt/homebrew/var/www` and ACME certificates go to `/opt/homebrew/var/acme`. Start it with `brew services start stychos/angie/angie` (`sudo brew services start ...` for port 80).

## Third-party modules

The options follow [Angie's own list of third-party modules](https://en.angie.software/angie/docs/installation/external-modules/). Each `--with-<name>-module` compiles the module in statically from the sources packaged in the `<name>-angie-module` formula of this tap (installed automatically). Libraries come from Homebrew.

| Option | Module | Upstream | Links against |
|---|---|---|---|
| `--with-auth-jwt-module` | JWT authentication | [kjdev/nginx-auth-jwt](https://github.com/kjdev/nginx-auth-jwt) | – |
| `--with-auth-ldap-module` | LDAP authentication | [kvspb/nginx-auth-ldap](https://github.com/kvspb/nginx-auth-ldap) | openldap |
| `--with-auth-pam-module` | PAM authentication | [sto/ngx_http_auth_pam_module](https://github.com/sto/ngx_http_auth_pam_module) | – |
| `--with-auth-spnego-module` | SPNEGO/Kerberos authentication | [stnoonan/spnego-http-auth-nginx-module](https://github.com/stnoonan/spnego-http-auth-nginx-module) | krb5 |
| `--with-auth-totp-module` | Time-based one-time password authentication | [61131/nginx-http-auth-totp](https://github.com/61131/nginx-http-auth-totp) | – |
| `--with-brotli-module` | Brotli compression | [google/ngx_brotli](https://github.com/google/ngx_brotli) | brotli |
| `--with-cache-purge-module` | Cache purging | [nginx-modules/ngx_cache_purge](https://github.com/nginx-modules/ngx_cache_purge) | – |
| `--with-cgi-module` | CGI | [pjincz/nginx-cgi](https://github.com/pjincz/nginx-cgi) | – |
| `--with-combined-upstreams-module` | Combined upstreams | [lyokha/nginx-combined-upstreams-module](https://github.com/lyokha/nginx-combined-upstreams-module) | – |
| `--with-dav-ext-module` | WebDAV extensions | [arut/nginx-dav-ext-module](https://github.com/arut/nginx-dav-ext-module) | libxml2 |
| `--with-dynamic-limit-req-module` | Dynamic request limiting module with Redis storage | [limithit/ngx_dynamic_limit_req_module](https://github.com/limithit/ngx_dynamic_limit_req_module) | hiredis |
| `--with-echo-module` | Echo, sleep, time and exec directives | [openresty/echo-nginx-module](https://github.com/openresty/echo-nginx-module) | – |
| `--with-enhanced-memcached-module` | Enhanced memcached | [bpaquet/ngx_http_enhanced_memcached_module](https://github.com/bpaquet/ngx_http_enhanced_memcached_module) | – |
| `--with-eval-module` | Eval | [openresty/nginx-eval-module](https://github.com/openresty/nginx-eval-module) | – |
| `--with-geoip2-module` | GeoIP2 | [leev/ngx_http_geoip2_module](https://github.com/leev/ngx_http_geoip2_module) | libmaxminddb |
| `--with-headers-more-module` | Set, add and clear arbitrary headers | [openresty/headers-more-nginx-module](https://github.com/openresty/headers-more-nginx-module) | – |
| `--with-http-auth-radius-module` | RADIUS authentication | [ten0s/ngx_http_auth_radius_module](https://github.com/ten0s/ngx_http_auth_radius_module) | – |
| `--with-keyval-module` | Key-value store module with shared memory and Redis | [kjdev/nginx-keyval](https://github.com/kjdev/nginx-keyval) | hiredis |
| `--with-lua-module` | Lua scripting (LuaJIT) with lua-resty-core | [openresty/lua-nginx-module](https://github.com/openresty/lua-nginx-module) | needs ndk (added automatically), luajit-openresty |
| `--with-modsecurity-module` | ModSecurity v3 connector | [owasp-modsecurity/ModSecurity-nginx](https://github.com/owasp-modsecurity/ModSecurity-nginx) | modsecurity |
| `--with-ndk-module` | Nginx Development Kit, needed by the lua and set-misc modules | [vision5/ngx_devel_kit](https://github.com/vision5/ngx_devel_kit) | – |
| `--with-njs-module` | JavaScript scripting | [nginx/njs](https://github.com/nginx/njs) | – |
| `--with-oidc-module` | OpenID Connect | [kjdev/nginx-oidc](https://github.com/kjdev/nginx-oidc) | hiredis |
| `--with-postgres-module` | PostgreSQL upstream | [FRiCKLE/ngx_postgres](https://github.com/FRiCKLE/ngx_postgres) | libpq |
| `--with-redis2-module` | Redis 2.0 protocol upstream | [openresty/redis2-nginx-module](https://github.com/openresty/redis2-nginx-module) | – |
| `--with-rtmp-module` | RTMP streaming | [arut/nginx-rtmp-module](https://github.com/arut/nginx-rtmp-module) | – |
| `--with-set-misc-module` | Various set_xxx directives | [openresty/set-misc-nginx-module](https://github.com/openresty/set-misc-nginx-module) | needs ndk (added automatically) |
| `--with-stream-lua-module` | Lua scripting (LuaJIT) for the stream subsystem | [openresty/stream-lua-nginx-module](https://github.com/openresty/stream-lua-nginx-module) | luajit-openresty |
| `--with-stream-sts-module` | Stream server traffic status | [vozlt/nginx-module-stream-sts](https://github.com/vozlt/nginx-module-stream-sts) | – |
| `--with-sts-module` | Stream server traffic status | [vozlt/nginx-module-sts](https://github.com/vozlt/nginx-module-sts) | – |
| `--with-subs-module` | Substitutions filter | [yaoweibin/ngx_http_substitutions_filter_module](https://github.com/yaoweibin/ngx_http_substitutions_filter_module) | – |
| `--with-testcookie-module` | Cookie-based DDoS protection | [kyprizel/testcookie-nginx-module](https://github.com/kyprizel/testcookie-nginx-module) | – |
| `--with-unbrotli-module` | Brotli decompression filter | [clyfish/ngx_unbrotli](https://github.com/clyfish/ngx_unbrotli) | brotli |
| `--with-unzstd-module` | Zstandard decompression filter | [HanadaLee/ngx_http_unzstd_filter_module](https://github.com/HanadaLee/ngx_http_unzstd_filter_module) | zstd |
| `--with-upload-module` | Multipart upload handling | [fdintino/nginx-upload-module](https://github.com/fdintino/nginx-upload-module) | – |
| `--with-vod-module` | VOD on-the-fly MP4/HLS/DASH repackaging | [dio-az/nginx-vod-module](https://github.com/dio-az/nginx-vod-module) | – |
| `--with-vts-module` | Virtual host traffic status | [vozlt/nginx-module-vts](https://github.com/vozlt/nginx-module-vts) | – |
| `--with-zip-module` | ZIP archive streaming | [evanmiller/mod_zip](https://github.com/evanmiller/mod_zip) | – |
| `--with-zstd-module` | Zstandard compression | [myguard-labs/nginx-zstd-module](https://github.com/myguard-labs/nginx-zstd-module) | zstd |

Notes:

- Lua: `lua-resty-core` and `lua-resty-lrucache` ship inside `lua-angie-module` and are on the default `lua_package_path`, so Lua works without extra configuration; LuaJIT comes from `luajit-openresty`.
- njs is built without QuickJS; keyval is built with Redis support; vod is built without ffmpeg (no thumbnails or volume maps: the module needs ffmpeg 6, Homebrew ships 9).
- Small build-time fixes are applied to `http-auth-radius` (macOS byte-order helpers) and `postgres` (a field nginx 1.27 removed); see `angie-full.rb`.
- Not available: max-lt/nginx-jwt-module needs libjwt 1.x while Homebrew ships 3.x, and it clashes with the `auth-jwt` module name. Use `auth-jwt`.
- Module versions are pinned in the `<name>-angie-module` formulae. Angie does not review these modules and neither do we; please report build problems in this repository's issues.

## Bottles

CI builds bottles for macOS 15, macOS 26 and x86_64 Linux on every Angie release. macOS 27 "Golden Gate" bottles are built on a Mac with `scripts/bottle-local.sh` until GitHub ships a `macos-27` runner.

## Thanks

- [denji/homebrew-nginx](https://github.com/denji/homebrew-nginx) — the layout of this tap, a `-full` formula with one small source formula per module, is taken from there.
- [Web Server LLC](https://en.angie.software/), the developers of Angie — for the server itself and for curating and packaging the third-party modules this tap follows.
- [nginx](https://nginx.org/), its creator Igor Sysoev and the nginx team — the server Angie is built on.
- The authors of every module in the table above.
