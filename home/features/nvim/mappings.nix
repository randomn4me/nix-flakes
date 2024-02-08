{
  programs.neovim = {
    extraLuaConfig = /* lua */ ''
      vim.g.mapleader = " "

      vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Open Explorer" })
      vim.keymap.set("n", "H", "<cmd>bp<cr>", { desc = "Goto previous buffer" })
      vim.keymap.set("n", "L", "<cmd>bn<cr>", { desc = "Goto next buffer" })

      vim.keymap.set("n", "<leader>w", "<cmd>:w<cr>", { desc = "Save Buffer" })
      vim.keymap.set("n", "<leader>c", "<cmd>bd<cr>", { desc = "Close Buffer" })
      vim.keymap.set("n", "<leader>q", "<cmd>:q<cr>", { desc = "Quit Buffer" })

      vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "Copy to system clipboard" })
      vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Copy to system clipboard" })

      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
      vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format code" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
      vim.keymap.set("n", "<leader>c", vim.lsp.buf.code_action, { desc = "LSP code action" })

      -- Diagnostic
      vim.keymap.set("n", "<space>le", vim.diagnostic.open_float, { desc = "Floating diagnostic" })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
      vim.keymap.set("n", "gl", vim.diagnostic.setloclist, { desc = "Diagnostics on loclist" })
      vim.keymap.set("n", "gq", vim.diagnostic.setqflist, { desc = "Diagnostics on quickfix" })

      function add_sign(name, text)
        vim.fn.sign_define(name, { text = text, texthl = name, numhl = name})
      end
    '';
  };
}
