{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    vim-nix
    vim-markdown

    {
      plugin = telescope-nvim;
      type = "lua";
      config = /* lua */ ''
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>ps', function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end)
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
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

        vim.keymap.set("n", "<C-n>", function() ui.nav_file(1) end)
        vim.keymap.set("n", "<C-r>", function() ui.nav_file(2) end)
        vim.keymap.set("n", "<C-s>", function() ui.nav_file(3) end)
        vim.keymap.set("n", "<C-g>", function() ui.nav_file(4) end)
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
      type = "viml";
      config = /* vim */ ''
        nmap <space>G :Git<CR>
      '';
    }
  ];
}
