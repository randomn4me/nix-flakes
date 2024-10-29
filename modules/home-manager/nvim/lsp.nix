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
  config = mkIf cfg.lsp {
    programs.nixvim = {
      plugins = {
        lsp-format = {
          enable = true;
          lspServersToEnable = "all";
        };

        lsp = {
          enable = true;

          keymaps = {
            silent = true;
            diagnostic = {
              # Navigate in diagnostics
              "<leader>k" = "goto_prev";
              "<leader>j" = "goto_next";
            };

            lspBuf = {
              gd = "definition";
              gD = "references";
              gt = "type_definition";
              gi = "implementation";
              K = "hover";
              "<F2>" = "rename";
              "<leader>lf" = "format";
            };
          };

          servers = {
            nil_ls = {
              enable = true;
              settings.formatting.command = [ "nixfmt-rfc-style" ];
            };
            ltex = {
              enable = true;
              filetypes = [
                "latex"
                "tex"
                "bib"
                "markdown"
                "gitcommit"
                "text"
              ];
            };
            lua_ls.enable = true;
            pylsp.enable = true;
            ruff.enable = true;
            ruff_lsp.enable = true;
            rust_analyzer = {
              enable = true;
              installCargo = true;
              installRustc = true;
            };
            texlab.enable = true;
          };
        };
      };
    };
  };
}
