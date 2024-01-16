{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  perl
}:

stdenv.mkDerivation rec {
  version = "2.3.1";
  pname = "libcourier-unicode";

  src = fetchurl {
    url = "mirror://sourceforge/courier/courier-unicode/${version}/courier-unicode-${version}.tar.bz2";
    sha256 = "sha256-uD7mRqR8Kp1pL7bvuThWRmjDLsF51PrAwH6s6KG4/JE=";
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
