{ lib, ... }:
{
  programs.nixvim.plugins.lsp = {
    enable = lib.mkDefault true;

    servers = {
      nil_ls.enable = true;
      ltex.enable = true;
      lua-ls.enable = true;
      pylsp.enable = true;
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
