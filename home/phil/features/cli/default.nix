{ pkgs, ... }:
{
  imports = [
    ./bash.nix
    ./bat.nix
    ./eza.nix
    ./fzf.nix
    ./git.nix
    ./tmux.nix
    ./zoxide.nix
  ];
  home.packages = with pkgs; [
    bc
    jq

    ripgrep
    fd
    sd

    unzip
  ];
}
