{
  programs.nixvim.plugins.telescope = {
    enable = true;

    keymaps = {
      "<leader>ff" = "find_files";
      "<leader>fw" = "live_grep";
      "<leader>fb" = "buffers";
      "<leader>fh" = "help_tags";
      "<leader>fd" = "diagnostics";
    };

    keymapsSilent = true;

    defaults = {
      file_ignore_patterns = [
        "^.git/"
        ".pdf$"
        ".jpg$"
        ".jepg$"
        ".png$"
      ];
    };
  };
}



