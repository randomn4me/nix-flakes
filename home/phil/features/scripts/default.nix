{ pkgs, lib, ... }:
let
  myScriptBuilder = name: myDeps:
    let
      myName = builtins.toString name;
      myBuildInputs = [ pkgs.coreutils ] ++ myDeps;
      myScript = (pkgs.writeScriptBin myName
        (builtins.readFile ./raw/${myName}.sh)).overrideAttrs (old: {
          buildCommand = ''
            ${old.buildCommand}
             patchShebangs $out'';
        });
    in pkgs.symlinkJoin {
      name = myName;
      paths = [ myScript ] ++ myBuildInputs;
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = "wrapProgram $out/bin/${myName} --prefix PATH : $out/bin";
    };
in {
  home.packages = lib.mapAttrsToList (name: deps: (myScriptBuilder name deps)) {
    bat = with pkgs; [ gnugrep ];
    bone = with pkgs; [ libnotify xorg.xkbcomp ];
    bt = with pkgs; [ bluez ];
    checkwriting = with pkgs; [ perl ];
    intro = with pkgs; [ taskwarrior ];
    latex-cite-count = with pkgs; [ python3 ];
    mkv-to-av1 = with pkgs; [ ffmpeg ];
    mvc = [ ];
    pdffirstpage = with pkgs; [ poppler_utils ];
    pdfreduce = with pkgs; [ ghostscript ];
    presents = with pkgs; [ neovim ];
    radio = with pkgs; [ mpv ];
    rfc = with pkgs; [ curl ];
    sanitize-filename = [ ];
    scan = with pkgs; [ sane-backends imagemagick ];
    syscat = with pkgs; [ gnugrep ];
    tmx = with pkgs; [ fzf zoxide tmux ];
    vol = with pkgs; [ pamixer ];
    vpn = with pkgs; [ openconnect ];
    weather = with pkgs; [ curl ];
  };
}
