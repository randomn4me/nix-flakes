{
  programs.nixvim.plugins.lsp = {
    enable = true;

    keymaps = {
      silent = true;
      diagnostic = {
        "<leader>k" = "goto_prev";
        "<leader>j" = "goto_next";
      };

      lspBuf = {
        K = "hover";
        "<leader>lf" = "format";
        "<leader>gd" = "definition";
        "<leader>gD" = "references";
        "<leader>gt" = "type_definition";
        "<leader>gi" = "implementation";
        "<leader>lc" = "code_action";
        "<leader>lr" = "rename";
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
      ltex.enable = true;
    };
  };

  programs.nixvim.plugins.lsp-format.enable = true;

  programs.nixvim.plugins.nvim-cmp = {
    enable = true;
    sources = [
      { name = "nvim_lsp"; }
      { name = "path"; }
      { name = "buffer"; }
    ];
  };
}

