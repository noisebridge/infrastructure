# Custom Caddy build with the rate-limit plugin.
# Based on the caddy_packages from group_vars/noisebridge_net/caddy.yml.
final: prev:
{
  caddy-custom = prev.stdenv.mkDerivation rec {
    pname = "caddy-custom";
    version = "2.8.4";

    nativeBuildInputs = [ prev.go prev.xcaddy ];

    dontUnpack = true;

    buildPhase = ''
      export HOME=$TMPDIR
      export GOPATH=$TMPDIR/go
      ${prev.xcaddy}/bin/xcaddy build v${version} \
        --with github.com/mholt/caddy-ratelimit@v0.1.0 \
        --output caddy
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp caddy $out/bin/caddy
    '';

    meta = with prev.lib; {
      description = "Caddy web server with rate-limit plugin";
      homepage = "https://caddyserver.com";
      license = licenses.asl20;
    };
  };
}
