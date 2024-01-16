{
  fetchurl,
  lib,
  stdenv,
  pkg-config,
  pcre2,
  perl,
  darwin, libiconv, libidn2, libcourier-unicode
}:

stdenv.mkDerivation rec {
  pname = "maildrop";
  version = "3.1.8";

  src = fetchurl {
    url = "mirror://sourceforge/courier/maildrop/${version}/maildrop-${version}.tar.bz2";
    sha256 = "sha256-foJsAxkXRE8berccH82QODWVZEhG4rOyYONSsc4D6VA=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    pcre2
    perl
    libidn2
    libcourier-unicode
  ]
  ++ lib.optionals stdenv.isDarwin [
    libiconv darwin.apple_sdk.frameworks.Security ]
  ;

  patches = [ ./maildrop.configure.hack.patch ]; # for building in chroot

  doCheck = false; # fails with "setlocale: LC_ALL: cannot change locale (en_US.UTF-8)"

  meta = with lib; {
    homepage = "http://www.courier-mta.org/maildrop/";
    description = "Mail filter/mail delivery agent that is used by the Courier Mail Server";
    license = licenses.gpl3;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
