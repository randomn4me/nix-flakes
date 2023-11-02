{
  programs.neovim = {
    extraLuaConfig = # lua
      ''
        vim.g.mapleader = " "
        vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Open Explorer" })

        vim.keymap.set("n", "<leader>w", "<cmd>:w<cr>", { desc = "Save Buffer" })
        vim.keymap.set("n", "<leader>q", "<cmd>:q<cr>", { desc = "Quit Buffer" })

        vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "Copy to system clipboard" })
        vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Copy to system clipboard" })

        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
        vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format code" })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
        vim.keymap.set("n", "<leader>c", vim.lsp.buf.code_action, { desc = "Code action" })
      '';
  };
}
