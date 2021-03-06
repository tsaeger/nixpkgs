{ stdenv, lib, fetchFromGitHub, rustPlatform, makeWrapper, ffmpeg
, pandoc, poppler_utils, ripgrep, Security, imagemagick, tesseract
}:

rustPlatform.buildRustPackage rec {
  pname = "ripgrep-all";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "phiresky";
    repo = pname;
    rev = "v${version}";
    sha256 = "1nl03i36ilhxn5xbcry6pcr7vbl5667m43flpxaa0lf1wijzn5c2";
  };

  cargoSha256 = "0ndyd8qrvljkk6yvpsp0w17iizxb529sh5q2bj790m32x0gz2w8l";
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = lib.optional stdenv.isDarwin Security;

  postInstall = ''
    wrapProgram $out/bin/rga \
      --prefix PATH ":" "${lib.makeBinPath [ ffmpeg pandoc poppler_utils ripgrep imagemagick tesseract ]}"
  '';

  # Use upstream's example data to run a couple of queries to ensure the dependencies
  # for all of the adapters are available.
  installCheckPhase = ''
    set -e
    export PATH="$PATH:$out/bin"

    test1=$(rga --rga-no-cache "hello" exampledir/ | wc -l)
    test2=$(rga --rga-no-cache --rga-adapters=tesseract "crate" exampledir/screenshot.png | wc -l)

    if [ $test1 != 26 ]
    then
      echo "ERROR: test1 failed! Could not find the word 'hello' 26 times in the sample data."
      exit 1
    fi

    if [ $test2 != 1 ]
    then
      echo "ERROR: test2 failed! Could not find the word 'crate' in the screenshot."
      exit 1
    fi
  '';

  doInstallCheck = true;

  meta = with stdenv.lib; {
    description = "Ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz, and more";
    longDescription = ''
      Ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz, etc.

      rga is a line-oriented search tool that allows you to look for a regex in
      a multitude of file types. rga wraps the awesome ripgrep and enables it
      to search in pdf, docx, sqlite, jpg, movie subtitles (mkv, mp4), etc.
    '';
    homepage = "https://github.com/phiresky/ripgrep-all";
    license = with licenses; [ agpl3Plus ];
    maintainers = with maintainers; [ zaninime ma27 ];
    platforms = platforms.all;
  };
}
