{
  lib,
  config,
  inputs,
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
    inputs.nixvim.homeManagerModules.nixvim
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
    programs.nixvim = {
      enable = true;

      defaultEditor = true;

      viAlias = true;
      vimAlias = true;

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
          key = "<leader>e";
          action = "<cmd>Ex<cr>";
          mode = [ "n" ];
          options = {
            desc = "Open netrw";
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
