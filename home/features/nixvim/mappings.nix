{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = ",";
    };

    keymaps = [
      {
        key = "<leader>q";
        action = "<cmd>q<cr>";
        mode = [ "n" ];
        options = {
          desc = "Quit vim";
        };
      }
      {
        key = "<leader>w";
        action = "<cmd>w<cr>";
        mode = [ "n" ];
        options = {
          desc = "Save buffer";
        };
      }
      {
        key = "<leader>e";
        action = "<cmd>Ex<cr>";
        mode = [ "n" ];
        options = {
          desc = "Open netrw";
        };
      }
      {
        key = "<leader>y";
        action = ''"+y'';
        mode = [
          "n"
          "v"
        ];
        options = {
          desc = "Copy to system clipboard";
        };
      }
    ];
  };
}
