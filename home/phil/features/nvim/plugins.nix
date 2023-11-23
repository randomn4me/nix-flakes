{ pkgs, inputs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins;
    let
      harpoon = pkgs.vimUtils.buildVimPlugin {
        name = "harpoon";
        src = pkgs.fetchFromGitHub {
          owner = "ThePrimeagen";
          repo = "harpoon";
          rev = "c1aebbad9e3d13f20bedb8f2ce8b3a94e39e424a";
          sha256 = "sha256-pSnFx5fg1llNlpTCV4hoo3Pf1KWnAJDRVSe+88N4HXM=";
        };

      };

      resession = pkgs.vimUtils.buildVimPlugin {
        name = "resession";
        src = pkgs.fetchFromGitHub {
          owner = "stevearc";
          repo = "resession.nvim";
          rev = "b0107dc2cec1f24cf5a90a794a652eb66178ad8e";
          sha256 = "sha256-/a36sfzgxDBEcA7zuYto1QmEE+Mhl3wrrL3KZg0aP24=";
        };

      };
    in [
      vim-nix
      vim-markdown

      {
        plugin = telescope-nvim;
        type = "lua";
        config = # lua
          ''
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
        plugin = telescope-undo-nvim;
        type = "lua";
        config = # lua
          ''
            require("telescope").setup({
              extensions = {
                undo = {
                  side_by_side = true,
                  layout_config = {
                    preview_height = 0.8,
                  },
                },
              },
            })

            vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
          '';
      }

      {
        plugin = harpoon;
        type = "lua";
        config = # lua
          ''
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
        config = # lua
          ''
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
        config = # lua
          ''
            require('leap').add_default_mappings()
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
        plugin = resession;
        type = "lua";
        config = # lua
          ''
            local resession = require('resession')
            resession.setup()
            vim.keymap.set('n', '<leader>ss', resession.save, { desc = "Save session" })
            vim.keymap.set('n', '<leader>sl', resession.load, { desc = "Load session" })
            vim.keymap.set('n', '<leader>sd', resession.delete, { desc = "Delete session" })
          '';
      }

    ];
}

