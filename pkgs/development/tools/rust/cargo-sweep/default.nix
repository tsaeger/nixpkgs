{ stdenv, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "cargo-sweep";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "holmgr";
    repo = pname;
    rev = "v${version}";
    sha256 = "0zwdrh4z5x79qs8cwmwh3phzy4brw0ggv2qyf6pylv99vha5acyf";
  };

  cargoSha256 = "1sxjc64g8h77a3dvzb99f1f72zrak1nh4jgfjfkw4yc4dhkpyrmz";

  meta = with stdenv.lib; {
    description = "A Cargo subcommand for cleaning up unused build files generated by Cargo";
    homepage = "https://github.com/holmgr/cargo-sweep";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ xrelkd ];
  };
}
