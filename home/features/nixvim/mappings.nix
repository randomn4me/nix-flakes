{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps = [
      {
        key = "<leader>q";
        action = "<cmd>q<cr>";
        mode = [ "n" ];
        options = {
          desc = "Quit vim";
          silent = true;
        };
      }
      {
        key = "<leader>w";
        action = "<cmd>w<cr>";
        mode = [ "n" ];
        options = {
          desc = "Save buffer";
          silent = true;
        };
      }
      {
        key = "<leader>y";
        action = ''[["+y]]'';
        mode = [ "n" "v" ];
        options = {
          desc = "Copy to system clipboard";
          silent = true;
        };
      }

      {
        key = "<leader>e";
        action = "<cmd>Ex<cr>";
        mode = [ "n" ];
        options = {
          desc = "Open explorer";
          silent = true;
        };
      }

      {
        key = "<leader>c";
        action = "<cmd>bd<cr>";
        mode = [ "n" ];
        options = {
          desc = "Close buffer";
          silent = true;
        };
      }
      {
        key = "H";
        action = "<cmd>bp<cr>";
        mode = [ "n" ];
        options = {
          desc = "Previous buffer";
          silent = true;
        };
      }
      {
        key = "L";
        action = "<cmd>bn<cr>";
        mode = [ "n" ];
        options = {
          desc = "Next buffer";
          silent = true;
        };
      }
    ];
  };
}
