{ pkgs, ... }:
{
  imports = [
    ./bash.nix
    ./taskwarrior.nix
    ./eza.nix
    ./bat.nix
    ./git.nix
    ./zoxide.nix
    ./tmux.nix
  ];
  home.packages = with pkgs; [
    bc
    ripgrep
    fd
    jq
  ];
}
