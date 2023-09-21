{ pkgs, ... }:
{
  imports = [
    ./bash.nix
    ./taskwarrior.nix
    ./eza.nix
    ./bat.nix
    #./direnv.nix
    ./git.nix
    #./shellcolor.nix
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
