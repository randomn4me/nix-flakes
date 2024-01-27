{ pkgs, config, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins;
    [
      vim-nix
      vim-markdown
      rust-vim
      vim-markdown
      vim-nix
      vim-toml
      haskell-vim

      {
        plugin = vimtex;
        type = "lua";
        config = /* lua */ ''
          vim.g.vimtex_view_method = '${if config.programs.zathura.enable then "zathura" else "general"}'
          vim.g.vimtex_compiler_latexmk = { out_dir = 'out', aux_dir = 'out' }

          vim.keymap.set('n', "<leader>vv", ':VimtexView<CR>', { desc = "View pdf file with vimtex", silent = true })
          vim.keymap.set('n', "<leader>vc", ':VimtexCompile<CR>', { desc = "Compile latex project with vimtex", silent = true })
          vim.keymap.set('n', "<leader>vd", function()
            local package_name = vim.fn.input("Documentation of package > ")
            if package_name ~= "" then
              vim.cmd("VimtexDocPackage " .. package_name)
            else
              print("No package provided")
            end
          end, { desc = "Open documentation for package.", silent = true })
        '';
      }

      {
        plugin = bufferline-nvim;
        type = "lua";
      }


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
          vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "View help" })
        '';
      }

      {
        plugin = undotree;
        type = "lua";
        config = /* lua */ ''
          vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
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
            }
          }
        '';
      }

      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = /* lua */ ''
          require("ibl").setup()
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

    ];
}

