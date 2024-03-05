{
  programs.nixvim = {
    plugins.fugitive.enable = true;
    keymaps = [
      {
        key = "<leader>g";
        action = "<cmd>:Git<cr>";
        options = {
          desc = "Open fugitive";
        };
      }
    ];
  };
}
