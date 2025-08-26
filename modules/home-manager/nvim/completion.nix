{
  lib,
  config,
  inputs,
  ...
}:

with lib;

let
  cfg = config.custom.nvim;
in
{
  config = mkIf cfg.completion {
    programs.nixvim = {
      opts.completeopt = [
        "menu"
        "menuone"
        "noselect"
      ];

      plugins = {
        luasnip = {
          enable = true;
          settings.enable_autosnippets = true;
        };

        lspkind = {
          enable = true;

          settings.cmp = {
            enable = true;
            menu = {
              nvim_lsp = "[LSP]";
              nvim_lua = "[api]";
              path = "[path]";
              luasnip = "[snip]";
              buffer = "[buffer]";
            };
          };
        };

        cmp = {
          enable = true;

          settings = {
            snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";

            mapping = {
              "<C-d>" = "cmp.mapping.scroll_docs(-4)";
              "<C-f>" = "cmp.mapping.scroll_docs(4)";
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-e>" = "cmp.mapping.close()";
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            };

            sources = [
              { name = "path"; }
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
            ];
          };
        };
      };

    };
  };
}
