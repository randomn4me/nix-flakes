{ lib
, stdenv
, makeWrapper
, zoxide
, tmux
, fzf
, coreutils
}:

with lib;

let
  scriptname = "tmx";
in
stdenv.mkDerivation {
  name = "${scriptname}";
  version = "1.0";
  src = ./${scriptname}.sh;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    install -Dm 0755 $src $out/bin/${scriptname}
    wrapProgram $out/bin/${scriptname} --set PATH \
      "${
        makeBinPath [
          zoxide
          tmux
          fzf
          coreutils
        ]
      }"
  '';

  meta = {
    description = "A tmux session handler using zoxide";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
