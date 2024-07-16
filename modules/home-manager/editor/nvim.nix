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
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  options.custom.nvim = {
    enable = mkEnableOption "Enable nvim";
    enableAllPlugins = mkOption {
      description = "Enable feature plugins";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;

      defaultEditor = true;

      viAlias = true;
      vimAlias = true;

      colorschemes.tokyonight = {
        enable = true;
        settings.style = "night";
      };

      highlight.ExtraWhitespace.bg = "red";
      match.ExtraWhitespace = "\\s\\+$";

      opts = {
        updatetime = 100;

        relativenumber = true;
        number = true;
        hidden = true;

        tabstop = 4;
        softtabstop = 4;
        shiftwidth = 4;
        expandtab = true;
        autoindent = true;

        wrap = true;
        linebreak = true;

        swapfile = false;
        backup = false;
        undofile = true;
        undodir = "${config.home.homeDirectory}/.vim/undo";

        hlsearch = true;
        incsearch = true;
        ignorecase = true;
        smartcase = true;

        scrolloff = 8;
        signcolumn = "yes";

        colorcolumn = "80";

        foldlevel = 99;

        completeopt = [
          "menu"
          "menuone"
          "noselect"
        ];
      };

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
        todo-comments = {
          enable = mkIf cfg.enableAllPlugins true;
          keymaps.todoTelescope.key = "<leader>ft";
        };

        treesitter = {
          enable = mkIf cfg.enableAllPlugins true;
          folding = true;
          settings = {
            languages.disable = [ "latex" ];
            #indent = true;
          };
          nixvimInjections = true;

        };

        treesitter-refactor = {
          enable = mkIf cfg.enableAllPlugins true;
          highlightDefinitions = {
            enable = true;
            clearOnCursorMove = false;
          };
        };

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
        fugitive.enable = true;

        cmp = {
          enable = mkIf cfg.enableAllPlugins true;
          autoEnableSources = true;
        };

        undotree.enable = true;

        lsp = {
          enable = mkIf cfg.enableAllPlugins true;

          servers = {
            nil-ls = {
              enable = true;
              settings.formatting.command = [ "nixfmt-rfc-style" ];
            };
            ltex = {
              enable = true;
              filetypes = [
                "latex"
                "tex"
                "bib"
                "markdown"
                "gitcommit"
                "text"
              ];
            };
            lua-ls.enable = true;
            #pylsp.enable = true;
            ruff.enable = true;
            ruff-lsp.enable = true;
            rust-analyzer = {
              enable = true;
              installCargo = true;
              installRustc = true;
            };
            texlab.enable = true;
          };

          keymaps = {
            lspBuf = {
              K = "hover";
              gD = "references";
              gd = "definition";
              gi = "implementation";
              gt = "type_definition";
              "<leader>c" = "code_action";
              "<leader>lf" = "format";
            };
          };
        };

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

        obsidian =
          let
            vaultPath = "${config.home.homeDirectory}/usr/docs/obsidian";
          in
          mkIf cfg.enableAllPlugins {
            enable = true;
            settings = {
              workspaces = [
                {
                  name = "obsidian";
                  path = "${vaultPath}";
                }
              ];

              dailyNotes = {
                folder = "journal";
                template = "templates/journaling";
              };

              noteIdFunc = # lua
                ''
                  function(title)
                  return title
                  end
                '';

              templates.subdir = "templates";
              completion.newNotesLocation = "notes_subdir";
            };
          };

        none-ls = {
          enable = mkIf cfg.enableAllPlugins true;
          enableLspFormat = true;
        };

        gitsigns.enable = mkIf cfg.enableAllPlugins true;
        leap.enable = true;
        lualine.enable = true;
        lsp-format.enable = mkIf cfg.enableAllPlugins true;
        neogen.enable = true;
        notify.enable = mkIf cfg.enableAllPlugins true;
        trouble.enable = mkIf cfg.enableAllPlugins true;
        nvim-colorizer.enable = mkIf cfg.enableAllPlugins true;
      };
    };
  };
}
