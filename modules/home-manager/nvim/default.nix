{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.nvim;
in
{
  imports = [
    ./lsp.nix
    ./completion.nix
    ./coreplugins.nix
    ./allplugins.nix
    inputs.nixvim.homeModules.nixvim
  ];

  options.custom.nvim = {
    enable = mkEnableOption "Enable nvim";
    completion = mkEnableOption "Enable nvim completion";
    lsp = mkEnableOption "Enable nvim lsp";
    allPlugins = mkEnableOption "Enable all predefined plugins";

    corePlugins = mkOption {
      description = "Enable core plugins";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.gcc ];

    programs.nixvim = {
      enable = true;

      defaultEditor = true;

      viAlias = true;
      vimAlias = true;

      # Startup cost is dominated by rtp scanning and lua parsing; byte-compiling
      # and merging the plugin pack cuts both. lz-n keeps the rarely-used plugins
      # out of the startup path (combinePlugins leaves `opt` plugins standalone,
      # so the two compose).
      performance = {
        byteCompileLua = {
          enable = true;
          plugins = true;
          nvimRuntime = true;
        };
        combinePlugins = {
          enable = true;
          # Kept out of the merged pack because their files collide: oil,
          # conform and blink all ship `doc/recipes.md`, and snacks ships a
          # `queries/lua/highlights.scm` that clashes with the treesitter
          # queries.
          standalonePlugins = [
            "conform.nvim"
            "oil.nvim"
            "snacks.nvim"
          ];
        };
      };

      plugins.lz-n.enable = true;

      colorschemes.tokyonight = {
        enable = true;
        settings.style = "night";
      };

      highlight.ExtraWhitespace.bg = "red";
      match.ExtraWhitespace = "\\s\\+$";

      opts = {
        updatetime = 100;

        relativenumber = true;
        number = true;
        hidden = true;

        tabstop = 4;
        softtabstop = 4;
        shiftwidth = 4;
        expandtab = true;
        autoindent = true;

        wrap = true;
        linebreak = true;

        swapfile = false;
        backup = false;
        undofile = true;
        undodir = "${config.home.homeDirectory}/.vim/undo";

        hlsearch = true;
        incsearch = true;
        ignorecase = true;
        smartcase = true;

        scrolloff = 8;
        signcolumn = "yes";

        colorcolumn = "80";

        foldlevel = 99;
      };

      globals = {
        mapleader = " ";
        maplocalleader = ",";
      };

      keymaps = [
        {
          key = "<leader>q";
          action = "<cmd>q<cr>";
          mode = [ "n" ];
          options = {
            desc = "Quit vim";
          };
        }
        {
          key = "<leader>w";
          action = "<cmd>w<cr>";
          mode = [ "n" ];
          options = {
            desc = "Save buffer";
          };
        }
        {
          key = "<leader>y";
          action = ''"+y'';
          mode = [
            "n"
            "v"
          ];
          options = {
            desc = "Copy to system clipboard";
          };
        }
      ];
    };
  };
}
