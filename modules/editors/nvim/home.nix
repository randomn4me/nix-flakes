{ config, pkgs, ... }:

{
  imports = [
    ./lsp.nix
    ./ui.nix
    ./setup.nix
    ./plugins.nix
  ];

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    extraLuaConfig = /* lua */ ''
      vim.g.mapleader = " "
      vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Open Explore" })

      vim.keymap.set("n", "<leader>w", "<cmd>:w<cr>", { desc = "Save Buffer" })
      vim.keymap.set("n", "<leader>q", "<cmd>:q<cr>", { desc = "Quit Buffer" })

      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
      vim.keymap.set("n", "<space>f", vim.lsp.buf.format, { desc = "Format code" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
      vim.keymap.set("n", "<space>c", vim.lsp.buf.code_action, { desc = "Code action" })
    '';

    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
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
    ];
  };
}
