{ pkgs, ... }:
{
  imports = [
    ./bash.nix
    ./taskwarrior.nix
    ./eza.nix
    ./bat.nix
    ./git.nix
    ./zoxide.nix
  ];
  home.packages = with pkgs; [
    bc
    ripgrep
    fd
    jq

    nil
    nixfmt

    ltex-ls
  ];
}
