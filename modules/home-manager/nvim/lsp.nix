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
        lsp-format.enable = true;

        lsp = {
          enable = true;

          keymaps = {
            silent = true;
            diagnostic = {
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
              "<leader>c" = "code_action";
              "<leader>lf" = "format";
            };
          };

          servers = {
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
            nixd = {
              enable = true;
              settings.formatting.command = [ "nixfmt" ];
            };
            pylsp.enable = true;
            ruff.enable = true;
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
