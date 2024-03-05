{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim

    ./plugins
    ./options.nix
    ./mappings.nix
  ];

  programs.nixvim = {
    enable = true;
    enableMan = true;

    defaultEditor = true;

    viAlias = true;
    vimAlias = true;

    colorschemes.tokyonight = {
      enable = true;
      style = "night";
    };

    options = {
      updatetime = 100;

      relativenumber = true;
      number = true;
      hidden = true;

      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      autoindent = true;

      swapfile = false;
      backup = false;
      undofile = true;

      hlsearch = false;
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
        action = ''[["+y]]'';
        mode = [ "n" "v" ];
        options = {
          desc = "Copy to system clipboard";
        };
      }
    ];
  };
}
