{ lib, ... }:
{
  programs.nixvim.plugins.lsp = {
    enable = lib.mkDefault true;

    servers = {
      nil-ls.enable = true;
      ltex = {
        enable = true;
        filetypes = [ "tex" ];
      };
      lua-ls.enable = true;
      pylsp.enable = true;
      ruff.enable = true;
      ruff-lsp.enable = true;
      rust-analyzer = {
        enable = true;
        installCargo = true;
        installRustc = true;
      };
      texlab.enable = true;
    };

    keymaps = {
      lspBuf = {
        K = "hover";
        gD = "references";
        gd = "definition";
        gi = "implementation";
        gt = "type_definition";
        "<leader>c" = "code_action";
        "<leader>lf" = "format";
      };
    };
  };
}
