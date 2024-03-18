{ pkgs, config, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = trouble-nvim;
      type = "lua";
      config = # lua
        ''
          require("trouble").setup({
            icons = false,
          })

          vim.keymap.set("n", "<leader>tt", function() require("trouble").toggle(); end)
          vim.keymap.set("n", "[t", function() require("trouble").previous({skip_groups = true, jump = true}); end)
          vim.keymap.set("n", "]t", function() require("trouble").next({skip_groups = true, jump = true}); end)
        '';
    }

    {
      plugin = vimtex;
      type = "lua";
      config = # lua
        ''
          vim.g.vimtex_view_method = '${if config.programs.zathura.enable then "zathura" else "general"}'
          vim.g.vimtex_compiler_latexmk = { out_dir = 'out', aux_dir = 'out' }
        '';
    }

    {
      plugin = telescope-nvim;
      type = "lua";
      config = # lua
        ''
          require('telescope').setup({
            defaults = {
              layout_strategy = "horizontal",
              layout_config = {
                horizontal = {
                  prompt_position = "top",
                  preview_width = 0.5,
                },
                width = 0.8,
                height = 0.8,
                preview_cutoff = 120,
              },
              sorting_strategy = "ascending",
              winblend = 0,
            }
          })
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find in all files" })
          vim.keymap.set('n', '<leader>fw', builtin.live_grep, { desc = "Find files by word" })
          vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "View help" })
          vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = "Find in git files" })
        '';
    }

    {
      plugin = todo-comments-nvim;
      type = "lua";
      config = # lua
        ''
          local todo_comments = require('todo-comments')

          todo_comments.setup()

          vim.keymap.set('n', ']t', function() todo_comments.jump_next() end, { desc = "Next todo comment" })
          vim.keymap.set('n', '[t', function() todo_comments.jump_prev() end, { desc = "Previous todo comment" })

          vim.keymap.set('n', '<leader>ft', vim.cmd.TodoTelescope, { desc = "Search todos via telescope" })
        '';
    }

    {
      plugin = harpoon;
      type = "lua";
      config = # lua
        ''
          local mark = require("harpoon.mark")
          local ui = require("harpoon.ui")

          vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "Add file to harpoon" })
          vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

          vim.keymap.set("n", "<C-j>", function() ui.nav_file(1) end)
          vim.keymap.set("n", "<C-k>", function() ui.nav_file(2) end)
          vim.keymap.set("n", "<C-l>", function() ui.nav_file(3) end)
          vim.keymap.set("n", "<C-ö>", function() ui.nav_file(4) end)
        '';
    }

    {
      plugin = nvim-treesitter.withAllGrammars;
      type = "lua";
      config = # lua
        ''
          require('nvim-treesitter.configs').setup{
              indent = { enable = true, },
            highlight = {
              enable = true,
              disable = { "latex" },
              additional_vim_regex_highlighting = { "markdown" },
            },
          }
        '';
    }

    {
      plugin = indent-blankline-nvim;
      type = "lua";
      config = # lua
        ''
          require("ibl").setup{
            indent = { char = "▏" },
            scope = { show_start = false, show_end = false },
            exclude = {
              buftypes = {
                "nofile",
                "terminal",
              },
              filetypes = {
                "help",
                "dashboard",
                "lazy",
                "neogitstatus",
                "Trouble",
              },
            },
          }
        '';
    }

    {
      plugin = vim-fugitive;
      type = "lua";
      config = # lua
        ''
          vim.keymap.set("n", "<leader>g", "<cmd>:Git<cr>", { desc = "Open Git interface" })
        '';
    }

    {
      plugin = leap-nvim;
      type = "lua";
      config = # lua
        ''
          require("leap").create_default_mappings()
        '';
    }

    {
      plugin = obsidian-nvim;
      type = "lua";
      config = # lua
        ''
          require("obsidian").setup {
              workspaces = {
                {
                  name = "vault",
                  path = "~/usr/docs/obsidian",
                  overrides = {
                    notes_subdir = "~/usr/docs/obsidian",
                  },
                },
              },

              daily_notes = {
                folder = "notes/journal",
                date_format = "%Y-%m-%d",
                template = "templates/journaling",
              },

              completion = {
                nvim_cmp = true,
                min_chars = 2,
              },

              mappings = {
                ["gf"] = {
                  action = function()
                    return require("obsidian").util.gf_passthrough()
                  end,
                  opts = { noremap = false, expr = true, buffer = true },
                },
              },

              new_notes_location = "notes_subdir",

              note_id_func = function(title)
                return title
              end,

              templates = {
                subdir = "templates",
                date_format = "%Y-%m-%d",
                time_format = "%H:%M",
                -- A map for custom variables, the key should be the variable and the value a function
                substitutions = {},
              },

              follow_url_func = function(url)
                -- Open the URL in the default web browser.
                vim.fn.jobstart({"xdg-open", url})  -- linux
              end,

              picker = {
                name = "telescope.nvim",
                -- Optional, configure key mappings for the picker. These are the defaults.
                -- Not all pickers support all mappings.
                mappings = {
                  -- Create a new note from your query.
                  new = "<C-x>",
                  -- Insert a link to the selected note.
                  insert_link = "<C-l>",
                },
              },
            }
        '';
    }
  ];
}
