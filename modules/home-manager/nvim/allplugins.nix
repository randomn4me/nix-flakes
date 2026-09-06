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
          key = "<leader>u";
          action = "<cmd>:UndotreeToggle<cr>";
          options = {
            desc = "Open undotree";
          };
        }
      ];

      plugins = {
        harpoon.enable = true;

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

        conform-nvim = {
          enable = true;
          settings = {
            default_format_opts.lsp_format = "fallback";

            format_on_save.lsp_format = "fallback";

            formatters_by_ft = {
              nix = [ "nixfmt" ];
              python = [
                "ruff_fix"
                "ruff_format"
              ];
              "_" = [
                "trim_newlines"
              ];
            };
            formatters = {
              ruff_fix.command = lib.getExe pkgs.ruff;
              ruff_format.command = lib.getExe pkgs.ruff;
              nixfmt.command = lib.getExe pkgs.nixfmt;
            };
          };
        };

        todo-comments = {
          enable = true;
          keymaps.todoTelescope.key = "<leader>ft";
        };

        which-key.enable = true;
        undotree = {
          enable = true;
          lazyLoad.settings.cmd = [
            "UndotreeToggle"
            "UndotreeShow"
            "UndotreeFocus"
          ];
        };

        chatgpt = {
          enable = true;
          settings =
            let
              myActions = {
                expandList = {
                  type = "chat";
                  opts = {
                    template = "I want you to act as a computer security scientist. Imagine you're working on an academic paper using cutting edge technology. You've been tasked with expanding the following bullet points to at least one paragraph.";
                    strategy = "edit";
                    params.model = "gpt-3.5-turbo";
                  };
                };
                args = {
                  argument = {
                    type = "string";
                    optional = "false";
                  };
                };
              };

              customActionsFile = builtins.toFile "customActions.json" (builtins.toJSON myActions);
            in
            {
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
          lazyLoad.settings.cmd = "Neogen";
          keymaps.generate = "<leader>n";
        };
        barbecue.enable = true;
        notify = {
          enable = true;
          settings = {
            render = "compact";
            stages = "static";
          };
        };
        trouble = {
          enable = true;
          lazyLoad.settings.cmd = "Trouble";
        };
        colorizer.enable = true;
        refactoring = {
          enable = true;
          enableTelescope = true;
        };

        obsidian = {
          enable = true;
          lazyLoad.settings.ft = "markdown";
          settings = {
            completion = {
              min_chars = 2;
            };
            new_notes_location = "notes_subdir";
            note_id_func = ''
              function(title)
                return title
              end

            '';
            workspaces = [
              {
                name = "notes";
                path = "~/usr/docs/obsidian";
              }
            ];
            templates.folder = "templates";
            frontmatter.enabled = false;
            legacy_commands = false;
          };

        };
      };
    };
  };
}
