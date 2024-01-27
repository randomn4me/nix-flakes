{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps = [
      {
        key = "<leader>q";
        action = "<cmd>:q<cr>";
        mode = [ "n" ];
        options = {
          desc = "Quit vim";
        };
      }
      {
        key = "<leader>w";
        action = "<cmd>:w<cr>";
        mode = [ "n" ];
        options = {
          desc = "Save buffer";
        };
      }
      {
        key = "<leader>y";
        action = ''[["+y]]'';
        mode = [ "n" "v" ];
        options = {
          desc = "Copy to system clipboard";
        };
      }

      {
        key = "<leader>c";
        action = "<cmd>bd<cr>";
        mode = [ "n" ];
        options = {
          desc = "Close buffer";
        };
      }
      {
        key = "H";
        action = "<cmd>bp<cr>";
        mode = [ "n" ];
        options = {
          desc = "Previous buffer";
        };
      }
      {
        key = "L";
        action = "<cmd>bn<cr>";
        mode = [ "n" ];
        options = {
          desc = "Next buffer";
        };
      }
    ];
  };
}
