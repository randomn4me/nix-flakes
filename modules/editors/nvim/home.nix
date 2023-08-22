{ config, lib, pkgs, host, system, nixvim, ... }:

{
  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    extraConfig = ''
      set number relativenumber
    '';

    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-markdown
      harpoon
      telescope-nvim
    ];
  };
}
