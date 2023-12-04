{ pkgs, ... }: {
  imports = [
    ./setup.nix
    ./lsp.nix
    ./plugins.nix
    ./mappings.nix
    ./ui.nix
  ];

  home.packages = with pkgs; [
    nil
    nixfmt

    texlab
    ltex-ls

    rust-analyzer
  ];

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    defaultEditor = true;

    extraPackages = with pkgs; [ tree-sitter gcc ];

  };
}
