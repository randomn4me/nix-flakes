{ config, lib, pkgs, host, system, nixvim, ... }:

{
  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    extraLuaConfig = ''
      vim.opt.nu = true
      vim.opt.relativenumber = true

      vim.opt.tabstop = 4
      vim.opt.softtabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.expandtab = true

      vim.opt.smartindent = true

      vim.opt.wrap = false

      vim.opt.swapfile = false
      vim.opt.backup = false
      vim.opt.undodir = os.getenv("XDG_CACHE_HOME") .. "/vim/undodir"
      vim.opt.undofile = true

      vim.opt.hlsearch = false
      vim.opt.incsearch = true

      vim.opt.termguicolors = true

      vim.opt.scrolloff = 8
      vim.opt.signcolumn = "yes"
      vim.opt.isfname:append("@-@")

      vim.opt.updatetime = 50

      vim.opt.colorcolumn = "80"

      vim.g.mapleader = " "
      vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

      vim.keymap.set("n", "<leader>w", "<cmd>:w<cr>")
      vim.keymap.set("n", "<leader>q", "<cmd>:q<cr>")

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<C-p>', builtin.git_files, {})
      vim.keymap.set('n', '<leader>ps', function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") })
      end)
      vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})

      local mark = require("harpoon.mark")
      local ui = require("harpoon.ui")

      vim.keymap.set("n", "<leader>a", mark.add_file)
      vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

      vim.keymap.set("n", "<C-n>", function() ui.nav_file(1) end)
      vim.keymap.set("n", "<C-r>", function() ui.nav_file(2) end)
      vim.keymap.set("n", "<C-s>", function() ui.nav_file(3) end)
      vim.keymap.set("n", "<C-g>", function() ui.nav_file(4) end)
    '';

    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-markdown
      telescope-nvim
      harpoon
      {
        plugin = rose-pine;
        config = "colorscheme rose-pine";
      }
    ];
  };
}
