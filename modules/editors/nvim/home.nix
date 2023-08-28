{ config, lib, pkgs, host, system, nixvim, ... }:

{
  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    extraLuaConfig = ''
      vim.g.mapleader = " "
      vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

      vim.keymap.set("n", "<leader>w", "<cmd>:w<cr>")
      vim.keymap.set("n", "<leader>w", "<cmd>:q<cr>")
    '';

    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-markdown
      telescope-nvim
      {
        plugin = rose-pine;
        config = "colorscheme rose-pine";
      }
    ];
  };
}
