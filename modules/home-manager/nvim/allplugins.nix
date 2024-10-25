{
  lib,
  config,
  inputs,
  ...
}:

with lib;

let
  cfg = config.custom.nvim;
in
{
  config = mkIf cfg.allPlugins {
    programs.nixvim = {
      keymaps = [
        {
          key = "<leader>g";
          action = "<cmd>:Git<cr>";
          options = {
            desc = "Open fugitive";
          };
        }
        {
          key = "<leader>u";
          action = "<cmd>:UndotreeToggle<cr>";
          options = {
            desc = "Open undotree";
          };
        }
      ];

      plugins = {
        cloak = {
          enable = true;
          settings = {
            cloak_character = "*";
            enabled = true;
            cloak_telescope = true;
            cloak_on_leave = false;
            patterns = [
              {
                file_pattern = [
                  ".env*"
                  "wrangler.toml"
                  ".dev.vars"
                ];
                cloak_pattern = "=.+";
                replace = null;
              }
            ];
          };
        };

        todo-comments = {
          enable = true;
          keymaps.todoTelescope.key = "<leader>ft";
        };

        which-key.enable = true;
        fugitive.enable = true;
        undotree.enable = true;

        vimtex = {
          enable = true;
          texlivePackage = null;
          settings = {
            view_method = if config.programs.zathura.enable then "zathura" else "general";
            compiler_latexmk = {
              out_dir = "out";
              aux_dir = "out";
            };
          };
        };

        gitsigns.enable = true;
        neogen = {
          enable = true;
          keymaps.generate = "<leader>n";
        };
        notify.enable = true;
        trouble.enable = true;
        nvim-colorizer.enable = true;
      };
    };
  };
}
