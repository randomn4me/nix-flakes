{
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.custom.nvim;
in
{
  config = mkIf cfg.corePlugins {
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
          key = "<leader>e";
          action = "<cmd>:Oil<cr>";
          options = {
            desc = "Open Oil";
          };
        }
      ];

      plugins = {
        fugitive.enable = true;
        oil.enable = true;

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
        leap.enable = true;
        lualine.enable = true;

        # Parsers already ship on the runtime path, but nothing started them:
        # every buffer was falling back to regex `syntax`.
        treesitter = {
          enable = true;
          highlight.enable = true;
          indent.enable = true;
          folding.enable = true;
        };
      };
    };
  };
}
