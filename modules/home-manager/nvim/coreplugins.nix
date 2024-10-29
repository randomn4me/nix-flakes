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
  config = mkIf cfg.corePlugins {
    programs.nixvim = {
      plugins = {
        treesitter = {
          enable = true;
          folding = true;
          settings = {
              auto_install = true;

              languages.disable = [ "latex" ];

              incremental_selection = {
                  enable = true;
                  keymaps = {
                      init_selection = "<C-space>";
                      node_decremental = "<bs>";
                      node_incremental = "<C-space>";
                      scope_incremental = false;
                  };
              };
              indent.enable = true;

          };
          nixvimInjections = true;
        };

        treesitter-refactor = {
          enable = true;
          highlightDefinitions = {
            enable = true;
            # Set to false if you have an `updatetime` of ~100.
            clearOnCursorMove = false;
          };
        };

        hmts.enable = true;

        telescope = {
          enable = true;

          keymaps = {
            "<leader>ff" = "find_files";
            "<leader>fw" = "live_grep";
            "<leader>fb" = "buffers";
            "<leader>fh" = "help_tags";
            "<leader>fd" = "diagnostics";
          };

          settings.defaults = {
            file_ignore_patterns = [
              "^.git/"
              ".pdf$"
              ".jpg$"
              ".jepg$"
              ".png$"
            ];
          };
        };
        web-devicons.enable = true;

        harpoon = {
          enable = true;
          keymaps = {
            addFile = "<leader>a";
            toggleQuickMenu = "<C-e>";

            navFile = {
              "1" = "<C-j>";
              "2" = "<C-k>";
              "3" = "<C-l>";
              "4" = "<C-ö>";
            };
          };
        };

        leap.enable = true;
        lualine.enable = true;
        trim.enable = true;
      };
    };
  };
}
