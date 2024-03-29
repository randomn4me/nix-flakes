{
  programs.neovim = {
    extraLuaConfig = # lua
      ''
        vim.g.mapleader = " "
        vim.g.maplocalleader = ","

        vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Open Explorer" })
        vim.keymap.set("n", "H", "<cmd>bp<cr>", { desc = "Goto previous buffer" })
        vim.keymap.set("n", "L", "<cmd>bn<cr>", { desc = "Goto next buffer" })

        vim.keymap.set("n", "<leader>w", "<cmd>:w<cr>", { desc = "Save Buffer" })
        vim.keymap.set("n", "<leader>c", "<cmd>bd<cr>", { desc = "Close Buffer" })
        vim.keymap.set("n", "<leader>q", "<cmd>:q<cr>", { desc = "Quit Buffer" })

        vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "Copy to system clipboard" })
        vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Copy to system clipboard" })


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
