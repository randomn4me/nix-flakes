{
  programs.nixvim = {
    plugins.undotree.enable = true;
    keymaps = [
      {
        key = "<leader>u";
        action = "<cmd>:UndotreeToggle<cr>";
        options = {
          desc = "Open undotree";
        };
      }
    ];
  };
}
