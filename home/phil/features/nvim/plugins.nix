{ pkgs, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    vim-nix
    vim-markdown

    {
      plugin = telescope-nvim;
      type = "lua";
      config = /* lua */ ''
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find in all files" })
        vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = "Find in git files" })
        vim.keymap.set('n', '<leader>fs', function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end, { desc = "Grep in all files" })
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, { desc = "View help" })
      '';
    }

    {
      plugin = harpoon;
      type = "lua";
      config = /* lua */ ''
        local mark = require("harpoon.mark")
        local ui = require("harpoon.ui")

        vim.keymap.set("n", "<leader>a", mark.add_file)
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
      config = /* lua */ ''
      require('nvim-treesitter.configs').setup{
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      }
      '';
    }

    {
      plugin = leap-nvim;
      type = "lua";
      config = /* lua */ ''
        require('leap').add_default_mappings()
      '';
    }

    {
      plugin = vim-fugitive;
      type = "lua";
      config = /* lua */ ''
        vim.keymap.set("n", "<leader>g", "<cmd>:Git<cr>", { desc = "Open Git interface" })
      '';
    }

    # {
    #   plugin = auto-session;
    #   type = "lua";
    #   config = /* lua */ ''
    #     require("auto-session").setup {
    #       log_level = "error",

    #       cwd_change_handling = {
    #         restore_upcoming_session = true, -- already the default, no need to specify like this, only here as an example
    #         pre_cwd_changed_hook = nil, -- already the default, no need to specify like this, only here as an example
    #         post_cwd_changed_hook = function() -- example refreshing the lualine status line _after_ the cwd changes
    #         require("lualine").refresh() -- refresh lualine so the new session name is displayed in the status bar
    #         end,
    #       },
    #     }
    #   '';
    # }
  ];
}


