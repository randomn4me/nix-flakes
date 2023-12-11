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

    neovim-remote
  ];

  home.sessionVariables.NVIM_LISTEN_ADDRESS = /tmp/nvimsocket;

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    defaultEditor = true;

    extraPackages = with pkgs; [ tree-sitter gcc ];
  };

  xdg.desktopEntries = {
    nvim = {
      name = "Neovim";
      genericName = "Text Editor";
      comment = "Edit text files";
      exec = "nvim %F";
      icon = "nvim";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
        "text/markdown"
      ];
      terminal = true;
      type = "Application";
      categories = [ "Utility" "TextEditor" ];
    };
  };
}
