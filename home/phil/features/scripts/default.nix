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
    # shell
    bat = with pkgs; [ gnugrep ];
    bone = with pkgs; [ libnotify xorg.xkbcomp xdg-utils ];
    bt = with pkgs; [ bluez ];
    checkwriting = with pkgs; [ perl ];
    intro = with pkgs; [ taskwarrior ];
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

    # python
    latex-cite-count = with pkgs; [ python3 ];

    # TODO
    # check-acm-approved = with pkgs; [ (python3.withPackages(ps: with ps; [ requests ])) ];

    # Comment from matrix:
    # you cannot install two python interpreters into the same environment
    # that's what creates that collision
    # the alternative would be to wrap your scripts
    # or package them using buildPythonApplication
    # ideally you'd create  a minimal pyproject.toml in that 
    # - https://setuptools.pypa.io/en/latest/userguide/quickstart.html
    # - https://nixos.wiki/wiki/Python
  };
}
