{ config, ... }:
{
  programs.nixvim.opts = {
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
}
