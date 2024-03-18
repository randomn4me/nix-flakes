{ pkgs, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = nvim-lspconfig;
      type = "lua";
      config = # lua
        ''
            local lspconfig = require('lspconfig')

            lspconfig.dockerls.setup {}
            lspconfig.bashls.setup {}
            lspconfig.nil_ls.setup {}
            lspconfig.pyright.setup {}
            lspconfig.pylsp.setup {}
            lspconfig.lua_ls.setup {}
            lspconfig.rust_analyzer.setup {}
            lspconfig.ltex.setup {}
            lspconfig.texlab.setup {}

            vim.api.nvim_create_autocmd('LspAttach', {
              group = vim.api.nvim_create_augroup('UserLspConfig', {}),
              callback = function(ev)

              vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

              local opts = { buffer = ev.buf }
              vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
              vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
              vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
              vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
              vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
              vim.keymap.set("n", "<leader>c", vim.lsp.buf.code_action, opts)
              vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format code", async = true })
              vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "LSP code action" })
            end,
          })
        '';
    }

    # Completions
    cmp-nvim-lsp
    cmp-buffer
    lspkind-nvim

    {
      plugin = nvim-cmp;
      type = "lua";
      config = # lua
        ''
          local cmp = require('cmp')

          cmp.setup{
            formatting = { format = require('lspkind').cmp_format() },

            -- Same keybinds as vim's vanilla completion
            mapping = cmp.mapping.preset.insert({
            }),

            sources = {
              { name='buffer', option = { get_bufnrs = vim.api.nvim_list_bufs } },
              { name='nvim_lsp' },
            },
          }
        '';
    }
  ];
}
