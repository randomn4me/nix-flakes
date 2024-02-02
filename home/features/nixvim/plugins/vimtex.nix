{
  programs.nixvim.plugins.vimtex = {
    enable = true;
    viewMethod = "zathura";
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "m";
      action = ":VimtexView<CR>";
      options.silent = true;
    }
  ];

  programs.nixvim.autoCmd = [
    {
      event = ["BufEnter" "BufWinEnter"];
      pattern = "*.tex";
      command = "set filetype=tex \"| VimtexTocOpen";
    }

    # Folding
    {
      event = "FileType";
      pattern = ["tex" "latex"];
      callback.__raw = ''
        function ()
        vim.o.foldmethod = 'expr'
        vim.o.foldexpr = 'vimtex#fold#level(v:lnum)'
        vim.o.foldtext = 'vimtex#fold#text()'
        end
      '';
    }

    # Compile on initialization
    {
      event = "User";
      pattern = "VimtexEventInitPost";
      callback = "vimtex#compiler#compile";
    }

    # Cleanup on exit
    {
      event = "User";
      pattern = "VimtexEventQuit";
      command = "call vimtex#compiler#clean(0)";
    }
  ];
}
