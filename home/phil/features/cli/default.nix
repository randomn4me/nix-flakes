{ pkgs, ... }:
{
  imports = [
    ./bash.nix
    #./bat.nix
    #./direnv.nix
    ./git.nix
    ./taskwarrior.nix
  ];
  home.packages = with pkgs; [
    bc
    exa
    ripgrep
    fd
    jq

    nil
    nixfmt

    ltex-ls
  ];
}

