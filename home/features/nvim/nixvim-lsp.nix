{
  programs.nixvim.plugins.lsp = {
    enable = true;

    keymaps = {
        silent = true;
        diagnostic = {
# Navigate in diagnostics
            "<leader>k" = "goto_prev";
            "<leader>j" = "goto_next";
        };

        lspBuf = {
            lf = "format";
            gd = "definition";
            gD = "references";
            gt = "type_definition";
            gi = "implementation";
            K = "hover";
            "<F2>" = "rename";
        };
    };

    servers = {
      nil_ls.enable = true;
      pyright.enable = true;

      rust-analyzer = {
        enable = true;
        installCargo = true;
        installRustc = true;

        autostart = true;
      };

      lua-ls.enable = true;
      ltex = {
        enable = true;

        settings = {
          additionalRules.motherTongue = "de-DE";
          additionalRules.enablePickyRules = true;
        };
      };
    };
  };
}
