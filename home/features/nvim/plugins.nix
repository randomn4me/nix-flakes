{ pkgs, config, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins;
    [
      {
        plugin = neogen;
        type = "lau";
        config = /* lua */ ''
          require('neogen').setup {}

          vim.keymap.set("n", "<localleader>nf", ":lua require('neogen').generate()<cr>", { desc = "Generate function annotations", silent = true })
          vim.keymap.set("n", "<localleader>nc", ":lua require('neogen').generate({type = 'class'})<cr>", { desc = "Generate class annotations", silent = true })
        '';
      }

      {
        plugin = trouble-nvim;
        type = "lua";
        config = /* lua */ ''
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
        config = /* lua */ ''
          vim.g.vimtex_view_method = '${if config.programs.zathura.enable then "zathura" else "general"}'
          vim.g.vimtex_mappings_prefix = '<localleader>v'
          vim.g.vimtex_compiler_latexmk = { out_dir = 'out', aux_dir = 'out' }
        '';
      }

      {
        plugin = telescope-nvim;
        type = "lua";
        config = /* lua */ ''
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find in all files" })
          vim.keymap.set('n', '<leader>fw', builtin.live_grep, { desc = "Find files by word" })
          vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = "Find in git files" })
          vim.keymap.set('n', '<leader>fs', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
            end, { desc = "Grep in all files" })
          vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "View help" })
        '';
      }

      {
        plugin = undotree;
        type = "lua";
        config = /* lua */ ''
          vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = "Open undotree" })
        '';
      }

      {
        plugin = harpoon;
        type = "lua";
        config = /* lua */ ''
          local mark = require("harpoon.mark")
          local ui = require("harpoon.ui")

          vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "Add file to harpoon" })
          vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

          vim.keymap.set("n", "<C-j>", function() ui.nav_file(1) end)
          vim.keymap.set("n", "<C-k>", function() ui.nav_file(2) end)
          vim.keymap.set("n", "<C-l>", function() ui.nav_file(3) end)
        '';
      }

      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = /* lua */ ''
          require('nvim-treesitter.configs').setup{
            highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
            }
          }
        '';
      }

      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = /* lua */ ''
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
        plugin = flash-nvim;
        type = "lua";
        config = /* lua */ ''
          require("flash").setup( {} )

          vim.keymap.set("n", "s", function () require('flash').jump() end, { desc = "Jump to .." })
        '';
      }

      {
        plugin = vim-fugitive;
        type = "lua";
        config = /* lua */ ''
          vim.keymap.set("n", "<leader>g", "<cmd>:Git<cr>", { desc = "Open Git interface" })
        '';
      }

    ];
}

