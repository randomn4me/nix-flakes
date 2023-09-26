{ lib, fetchFromGitHub }:

let
  pname = "sharetechmono";
  version = "1.0";
in fetchFromGitHub {
  name = "${pname}-${version}";
  
  owner = "google";
  repo = "fonts";
  rev = "439aeb22fa20de94856c7c849e1c2463ed49f9b3";
  sha256 = "dfFvh8h+oMhAQL9XKMrNr07VUkdQdxAsA8+q27KWWCA=";

  postFetch = ''
    tar xf $downloadedFile
    install -m444 -Dt $out/share/fonts/truetype *ttf
  '';

  meta = with lib; {
    description = "Share Tech Mono";
    longDescription = "Share Tech Mono is a monospaced sans serif, based on the Share family.";
    homepage = "https://github.com/google/fonts/ofl/sharetechmono";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ r4ndom ];
  };
}
