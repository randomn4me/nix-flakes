{ pkgs, ... }:
let
  myName = "vpn";
  myBuildInputs = with pkgs; [ coreutils openconnect ];
  myScript = (pkgs.writeScriptBin myName (builtins.readFile ./raw/${myName}.sh)).overrideAttrs(old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
  finalScript= pkgs.symlinkJoin {
    name = myName;
    paths = [ myScript ] ++ myBuildInputs;
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = "wrapProgram $out/bin/${myName} --prefix PATH : $out/bin";
  };
in {
  home.packages = [ finalScript ];
}
