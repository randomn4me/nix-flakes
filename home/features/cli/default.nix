{ pkgs, ... }: {
  imports = [
    ./bash.nix
    #./bat.nix
    ./eza.nix
    ./fzf.nix
    ./git.nix
    ./lyrics.nix
    ./tmux.nix
    ./xdg.nix
    ./zoxide.nix
  ];
  home.packages = with pkgs; [
    bc
    jq
    mdcat

    ripgrep
    fd
    sd

    zip
    unzip
  ];
}
