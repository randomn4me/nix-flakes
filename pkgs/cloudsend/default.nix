{ lib, stdenv, fetchFromGitHub, makeWrapper, curl }:

with lib;

stdenv.mkDerivation {
  pname = "cloudsend";
  version = "2.2.8";
  src = fetchFromGitHub {
    owner = "tavinus";
    repo = "cloudsend.sh";
    rev = "65abbc6d809bcce13870dc5ea07937d324283173";
    sha256 = "0";
  };

  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm 0755 cloudsend.sh $out/bin/cloudsend
    wrapProgram $out/bin/minicava --set PATH \
      "${makeBinPath [ curl ]}"
  '';

  meta = {
    description =
      "Bash script that uses curl to send files and folders to a nextcloud/owncloud publicly shared folder.";
    homepage = "https://github.com/tavinus/cloudsend.sh";
    license = licenses.agpl3Only;
    platforms = platforms.all;
  };

}
