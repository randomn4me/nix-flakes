{ pkgs, ... }:
{
  imports = [
    ./mappings.nix
    ./setup.nix
    ./lsp.nix
    ./plugins.nix
    ./ui.nix
  ];

  home.packages = with pkgs; [
    nil
    nixfmt

    texlab
    ltex-ls
  ];

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    defaultEditor = true;

    extraPackages = with pkgs; [
      tree-sitter
      gcc
    ];

  };
}
