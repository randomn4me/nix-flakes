{ pkgs, inputs, ... }: {
  # imports = [
  #   ./setup.nix
  #   ./lsp.nix
  #   ./plugins.nix
  #   ./mappings.nix
  #   ./ui.nix
  # ];

  home.sessionVariables.EDITOR = "nvim";
  # home.sessionVariables.NVIM_LISTEN_ADDRESS = /tmp/nvimsocket;

  xdg.configFile = {
    "nvim".source = inputs.astronvim;
    "astronvim/lua/user".source = ./astronvim-user;
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

  programs.neovim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      #-- c/c++
      cmake
      cmake-language-server
      gnumake
      checkmake
      gcc # c/c++ compiler, required by nvim-treesitter!
      llvmPackages.clang-unwrapped # c/c++ tools with clang-tools such as clangd
      gdb
      lldb

      #-- python
      nodePackages.pyright # python language server
      python3Packages.black # python formatter
      python3Packages.ruff-lsp
      (python3.withPackages (
        ps:
          with ps; [
            pynvim # Python client and plugin host for Nvim

            ipython
            pandas
            requests
            pyquery
            pyyaml
          ]
      ))

      #-- rust
      rust-analyzer
      cargo # rust package manager
      rustfmt

      #-- nix
      nil
      rnix-lsp
      # nixd
      statix # Lints and suggestions for the nix programming language
      deadnix # Find and remove unused code in .nix source files
      alejandra # Nix Code Formatter

      #-- lua
      stylua
      lua-language-server

      #-- bash
      nodePackages.bash-language-server
      shellcheck
      shfmt

      #-- javascript/typescript --#
      nodePackages.nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      # HTML/CSS/JSON/ESLint language servers extracted from vscode
      nodePackages.vscode-langservers-extracted
      nodePackages."@tailwindcss/language-server"

      #-- CloudNative
      nodePackages.dockerfile-language-server-nodejs
      # terraform  # install via brew on macOS
      terraform-ls
      jsonnet
      jsonnet-language-server
      hadolint # Dockerfile linter

      #-- Others
      taplo # TOML language server / formatter / validator
      nodePackages.yaml-language-server
      sqlfluff # SQL linter
      buf # protoc plugin for linting and formatting
      proselint # English prose linter
      guile # scheme language

      #-- Misc
      tree-sitter # common language parser/highlighter
      nodePackages.prettier # common code formatter
      marksman # language server for markdown
      texlab # tex
      ltex-ls # language-tool + tex
      glow # markdown previewer
      fzf

      #-- Optional Requirements:
      gdu # disk usage analyzer, required by AstroNvim
      ripgrep # fast search tool, required by AstroNvim's '<leader>fw'(<leader> is space key)
    ];
  };
}