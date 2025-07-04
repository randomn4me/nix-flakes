{ pkgs, lib, ... }:
let
  myScriptBuilder =
    name: myDeps:
    let
      myName = builtins.toString name;
      myBuildInputs = [ pkgs.coreutils ] ++ myDeps;
      myScript =
        (pkgs.writeScriptBin myName (builtins.readFile ./shell/${myName}.sh)).overrideAttrs
          (old: {
            buildCommand = ''
              ${old.buildCommand}
               patchShebangs $out'';
          });
    in
    pkgs.symlinkJoin {
      name = myName;
      paths = [ myScript ] ++ myBuildInputs;
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = "wrapProgram $out/bin/${myName} --prefix PATH : $out/bin";
    };
in
{
  home.packages = lib.mapAttrsToList (name: deps: (myScriptBuilder name deps)) {
    # shell
    bat = with pkgs; [ gnugrep ];
    bone = with pkgs; [
      libnotify
      xorg.xkbcomp
      xdg-utils
    ];
    bt = with pkgs; [ bluez ];
    mkv-to-av1 = with pkgs; [ ffmpeg ];
    mvc = [ ];
    paper-menu = with pkgs; [
      fd
      xdg-utils
    ];
    pdffirstpage = with pkgs; [ poppler_utils ];
    pdf-compress = with pkgs; [ ghostscript ];
    presents = [ ];
    radio = with pkgs; [ mpv ];
    rfc = with pkgs; [ curl ];
    sanitize-filename = [ ];
    scan = with pkgs; [
      sane-backends
      imagemagick
    ];
    shutdown-menu = with pkgs; [ systemd ];
    syscat = with pkgs; [ gnugrep ];
    tmx = with pkgs; [
      fzf
      tmux
    ];
    vol = with pkgs; [ wireplumber ];
    vpn = with pkgs; [ openconnect ];
    weather = with pkgs; [ curl ];

    # python
    latex-cite-count = with pkgs; [ python3 ];
  };
}
