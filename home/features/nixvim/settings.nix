{
  programs.nixvim.options = {
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
}

