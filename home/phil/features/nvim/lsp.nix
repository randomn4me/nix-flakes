{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = nvim-lspconfig;
      type = "lua";
      config = /* lua */ ''
        local lspconfig = require('lspconfig')

        function add_lsp(binary, server, options)
          options["cmd"] = { binary }
          if vim.fn.executable(binary) == 1 then server.setup(options) end
        end

        add_lsp("bash-language-server", lspconfig.bashls, {})
        add_lsp("nil", lspconfig.nil_ls, {})
        add_lsp("pylsp", lspconfig.pylsp, {})
        add_lsp("lua-lsp", lspconfig.lua_ls, {})
        add_lsp("texlab", lspconfig.texlab, {
          chktex = {
            onEdit = true,
            onOpenAndSave = true
          }
        })
        add_lsp("ltex-ls", lspconfig.ltex, {})
      '';
    }

    {
      plugin = rust-tools-nvim;
      type = "lua";
      config = /* lua */ ''
        local rust_tools = require('rust-tools')
        if vim.fn.executable("rust-analyzer") == 1 then
          rust_tools.setup{ tools = { autoSetHints = true } }
        end
        vim.api.nvim_set_hl(0, '@lsp.type.comment.rust', {})
      '';
    }

    # Completions
    cmp-nvim-lsp
    cmp-buffer
    lspkind-nvim

    {
      plugin = nvim-cmp;
      type = "lua";
      config = /* lua */ ''
        local cmp = require('cmp')

        cmp.setup{
          formatting = { format = require('lspkind').cmp_format() },
          -- Same keybinds as vim's vanilla completion
          mapping = {
            ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
            ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
            ['<C-e>'] = cmp.mapping.close(),
            ['<C-y>'] = cmp.mapping.confirm(),
          },
          sources = {
            { name='buffer', option = { get_bufnrs = vim.api.nvim_list_bufs } },
            { name='nvim_lsp' },
          },
        }
      '';
    }
  ];
}
