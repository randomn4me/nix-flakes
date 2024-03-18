{ pkgs, ... }:
{
  imports = [
    ./bash.nix
    ./direnv.nix
    ./eza.nix
    ./fzf.nix
    ./git.nix
    ./iamb.nix
    ./lyrics.nix
    ./tmux.nix
    ./xdg.nix
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
