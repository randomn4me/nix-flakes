{
  programs.nixvim.plugins.fugitive.enable = true;

  programs.nixvim.keymaps = [
    {
      key = "<leader>g";
      action = "<cmd>:Git<cr>";
      options = {
        desc = "Open fugitive";
      };
    }
  ];
}
