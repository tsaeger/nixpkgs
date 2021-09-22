{stdenv, lib, fetchFromGitHub, pkgconfig, autoconf, automake, libtool
, cyrus-sasl
}:

stdenv.mkDerivation rec {
  pname = "cyrus-sasl-xoauth2";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "moriyoshi";
    repo = pname;
    rev = "v${version}";
    sha256 = "1py9f1mn5k5xihrk0lfrwr6723c22gjb7lmgya83ibvislm2x3wl";
  };

  nativeBuildInputs = [ autoconf automake libtool pkgconfig ];
  buildInputs = [ cyrus-sasl.dev ];

  preConfigure = "./autogen.sh";

  installPhase = ''
    mkdir -p $out
    make install DESTDIR=$out
    '';

  meta = with lib; {
    description = "cyrus-sasl plugin implementation of XOAUTH2";
    homepage = "https://github.com/moriyoshi/cyrus-sasl-xoauth2";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ ];
  };
}
