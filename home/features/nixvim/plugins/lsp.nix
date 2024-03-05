{
  programs.nixvim.plugins.lsp = {
    enable = true;

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
    };

    keymaps = {
      lspBuf = {
        K = "hover";
        gD = "references";
        gd = "definition";
        gi = "implementation";
        gt = "type_definition";
        "<leader>lf" = "format";
      };
    };
  };
}
