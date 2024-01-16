{ lib, stdenv, fetchurl, pkg-config, perl }:

stdenv.mkDerivation rec {
  version = "2.3.0";
  pname = "libcourier-unicode";

  src = fetchurl {
    url = "mirror://sourceforge/courier/courier-unicode/${version}/courier-unicode-${version}.tar.bz2";
    sha256 = "sha256-ydmn02i6ohbRCcQjiZZJRvmIrJGUYNejgov5m35Qgg0=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ perl ];

  meta = with lib; {
    description = "Courier Unicode library";
    homepage = "http://www.courier-mta.org/maildrop/";
    license = licenses.gpl3;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
