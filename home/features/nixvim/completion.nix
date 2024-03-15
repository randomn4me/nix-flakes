{
  programs.nixvim = {
    options.completeopt = ["menu" "menuone" "noselect"];

    plugins = {
      luasnip.enable = true;

      lspkind = {
        enable = true;

        cmp = {
          enable = true;
          menu = {
            nvim_lsp = "[LSP]";
            nvim_lua = "[api]";
            path = "[path]";
            buffer = "[buffer]";
          };
        };
      };

      cmp = {
        enable = true;

        settings = {
          mapping = {
            "<C-y>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<C-CR>" = "cmp.mapping.complete()";
          };

          sources = [
            {name = "path";}
            {name = "nvim_lsp";}
            {
              name = "buffer";
              # Words from other open buffers can also be suggested.
              option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
            }
          ];
        };
      };
    };
  };
}
