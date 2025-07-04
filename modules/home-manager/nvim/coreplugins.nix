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
                init_selection = "<leader>s";
                node_decremental = "<bs>";
                node_incremental = "<leader>s";
                scope_incremental = false;
              };
            };
            indent.enable = true;

          };
          nixvimInjections = true;
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
        harpoon.enable = true;
        leap.enable = true;
        lualine.enable = true;
      };
    };
  };
}
