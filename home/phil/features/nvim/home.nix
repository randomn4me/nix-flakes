{ pkgs, ... }:

{
  imports = [
    ./mappings.nix
    ./setup.nix
    ./lsp.nix
    ./ui.nix
    ./plugins.nix
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
