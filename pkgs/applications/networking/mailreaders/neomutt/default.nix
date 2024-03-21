{ lib, stdenv, fetchFromGitHub, gettext, makeWrapper, tcl, which
, ncurses, perl , cyrus_sasl, gss, gpgme, libkrb5, libidn2, libxml2, notmuch, openssl
, lua, lmdb, libxslt, docbook_xsl, docbook_xml_dtd_42, w3m, mailcap, sqlite, zlib, lndir
, pkg-config, zstd, enableZstd ? true, enableMixmaster ? false, enableLua ? false
, withContrib ? true
, withCyrusSaslXoauth2 ? true, cyrus-sasl-xoauth2
}:

stdenv.mkDerivation rec {
  version = "20240425";
  pname = "neomutt";

  src = fetchFromGitHub {
    owner  = "neomutt";
    repo   = "neomutt";
    rev    = version;
    sha256 = "sha256-QBqPFteoAm3AdQN0XTWpho8DEW2BFCCzBcHUZIiSxyQ=";
  };

  buildInputs = [
    cyrus_sasl gss gpgme libkrb5 libidn2 ncurses
    notmuch openssl perl lmdb
    mailcap sqlite
  ]
  ++ lib.optional enableZstd zstd
  ++ lib.optional enableLua lua;

  nativeBuildInputs = [
    docbook_xsl docbook_xml_dtd_42 gettext libxml2 libxslt.bin makeWrapper tcl which zlib w3m
    pkg-config
  ]
    ++ lib.optionals withCyrusSaslXoauth2 [ makeWrapper ];

  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace auto.def --replace /usr/sbin/sendmail sendmail
    substituteInPlace contrib/smime_keys \
      --replace /usr/bin/openssl ${openssl}/bin/openssl

    for f in doc/*.{xml,xsl}*  ; do
      substituteInPlace $f \
        --replace http://docbook.sourceforge.net/release/xsl/current     ${docbook_xsl}/share/xml/docbook-xsl \
        --replace http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd ${docbook_xml_dtd_42}/xml/dtd/docbook/docbookx.dtd
    done


    # allow neomutt to map attachments to their proper mime.types if specified wrongly
    # and use a far more comprehensive list than the one shipped with neomutt
    substituteInPlace send/sendlib.c \
      --replace /etc/mime.types ${mailcap}/etc/mime.types
  '';

  configureFlags = [
    "--enable-autocrypt"
    "--gpgme"
    "--gss"
    "--lmdb"
    "--notmuch"
    "--ssl"
    "--sasl"
    "--with-homespool=mailbox"
    "--with-mailpath="
    # To make it not reference .dev outputs. See:
    # https://github.com/neomutt/neomutt/pull/2367
    "--disable-include-path-in-cflags"
    "--zlib"
  ]
  ++ lib.optional enableZstd "--zstd"
  ++ lib.optional enableLua "--lua"
  ++ lib.optional enableMixmaster "--mixmaster";

  postInstall = ''
    wrapProgram "$out/bin/neomutt" \
        --prefix PATH : "$out/libexec/neomutt" \
        ${lib.optionalString withCyrusSaslXoauth2 "--prefix SASL_PATH : ${lib.makeSearchPath "lib/sasl2" [ cyrus-sasl-xoauth2 ]}"}
  ''
  # https://github.com/neomutt/neomutt-contrib
  # Contains vim-keys, keybindings presets and more.
  + lib.optionalString withContrib "${lib.getExe lndir} ${passthru.contrib} $out/share/doc/neomutt";

  doCheck = false;

  preCheck = ''
    cp -r ${passthru.test-files} $(pwd)/test-files
    chmod -R +w test-files
    (cd test-files && ./setup.sh)

    export NEOMUTT_TEST_DIR=$(pwd)/test-files
  '';

  passthru = {
    test-files = fetchFromGitHub {
      owner = "neomutt";
      repo = "neomutt-test-files";
      rev = "1569b826a56c39fd09f7c6dd5fc1163ff5a356a2";
      sha256 = "sha256-MaH2zEH1Wq3C0lFxpEJ+b/A+k2aKY/sr1EtSPAuRPp8=";
    };
    contrib = fetchFromGitHub {
      owner = "neomutt";
      repo = "neomutt-contrib";
      rev = "8e97688693ca47ea1055f3d15055a4f4ecc5c832";
      sha256 = "sha256-tx5Y819rNDxOpjg3B/Y2lPcqJDArAxVwjbYarVmJ79k=";
    };
  };

  checkTarget = "test";
  postCheck = "unset NEOMUTT_TEST_DIR";

  meta = with lib; {
    description = "A small but very powerful text-based mail client";
    mainProgram = "neomutt";
    homepage    = "http://www.neomutt.org";
    license     = licenses.gpl2Plus;
    maintainers = with maintainers; [ erikryb vrthra ma27 raitobezarius ];
    platforms   = platforms.unix;
  };
}
