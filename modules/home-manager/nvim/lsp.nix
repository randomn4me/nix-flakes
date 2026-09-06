{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.nvim;

  # `lsp.keymaps` entries are plain keymaps; keep them silent like the old
  # `plugins.lsp.keymaps.silent` did.
  silent =
    key: attrs:
    attrs
    // {
      inherit key;
    }
    // {
      options = {
        silent = true;
      }
      // (attrs.options or { });
    };
in
{
  config = mkIf cfg.lsp {
    programs.nixvim = {
      # rustaceanvim brings rust-analyzer, but the analyzer still wants a
      # toolchain on PATH (this replaces installCargo/installRustc).
      extraPackages = with pkgs; [
        cargo
        rustc
      ];

      plugins = {
        # Provides the upstream default `vim.lsp.config` entries that
        # `lsp.servers` layers on top of.
        lspconfig.enable = true;

        # Supersedes `lsp.servers.rust_analyzer`: adds the rust-analyzer
        # extensions (macro expansion, runnables, debugging) the plain client
        # cannot express.
        rustaceanvim.enable = true;
      };

      # Native `vim.lsp` API (nvim 0.11+) instead of the nvim-lspconfig wrapper.
      lsp = {
        keymaps = [
          (silent "gd" { lspBufAction = "definition"; })
          (silent "gD" { lspBufAction = "references"; })
          (silent "gt" { lspBufAction = "type_definition"; })
          (silent "gi" { lspBufAction = "implementation"; })
          (silent "K" { lspBufAction = "hover"; })
          (silent "<leader>lr" { lspBufAction = "rename"; })
          (silent "<leader>c" { lspBufAction = "code_action"; })
          (silent "<leader>lf" { lspBufAction = "format"; })
          # goto_prev/goto_next are deprecated since nvim 0.11.
          (silent "<leader>k" {
            action.__raw = "function() vim.diagnostic.jump({ count = -1, float = true }) end";
          })
          (silent "<leader>j" {
            action.__raw = "function() vim.diagnostic.jump({ count = 1, float = true }) end";
          })
        ];

        servers = {
          lua_ls.enable = true;

          nixd = {
            enable = true;
            config.settings.nixd.formatting.command = [ "nixfmt" ];
          };

          # basedpyright for types, ruff for lint/format. pylsp bundled its own
          # linters and duplicated ruff's diagnostics.
          basedpyright.enable = true;
          ruff = {
            enable = true;
            # Leave hover to basedpyright.
            config.on_attach.__raw = ''
              function(client, _)
                client.server_capabilities.hoverProvider = false
              end
            '';
          };

          texlab.enable = true;

          # ltex-ls has been unmaintained since 2023; ltex-ls-plus is the
          # maintained fork. Prose and papers only.
          ltex_plus = {
            enable = true;
            package = pkgs.ltex-ls-plus;
            config.filetypes = [
              "tex"
              "bib"
              "markdown"
            ];
          };

          # Harper starts instantly, unlike ltex's JVM, which matters for the
          # buffers that are opened and closed in seconds.
          harper_ls = {
            enable = true;
            config.filetypes = [
              "gitcommit"
              "text"
            ];
          };
        };
      };
    };
  };
}
