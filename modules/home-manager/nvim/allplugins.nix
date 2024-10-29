{
  lib,
  config,
  pkgs,
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

        chatgpt = {
          enable = true;
          settings = let
            myActions = {
              expandList = {
                type = "chat";
                opts = {
                  template = "I want you to act as a computer security scientist. Imagine you're working on an academic paper using cutting edge technology. You've been tasked with expanding the following bullet points to at least one paragraph.";
                  strategy = "edit";
                  params.model = "gpt-3.5-turbo";
                };
              };
            };

            customActionsFile = builtins.toFile "customActions.json" (builtins.toJSON myActions);
          in {
            api_key_cmd =
              let
                cat = "${pkgs.coreutils}/bin/cat";
              in
              "${cat} ${config.home.homeDirectory}/usr/misc/chatgpt-apikey";
            openapi_params.model = "gpt-4o-mini";
            actions_path = customActionsFile;
          };
        };

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
