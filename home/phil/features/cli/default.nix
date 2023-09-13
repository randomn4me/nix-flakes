{ pkgs, ... }:
{
  imports = [
    ./bash.nix
    #./bat.nix
    #./direnv.nix
    #./git.nix
    #./shellcolor.nix
  ];
  home.packages = with pkgs; [
    bc
    eza
    ripgrep
    fd
    jq

    nil
    nixfmt

    ltex-ls
  ];
}
