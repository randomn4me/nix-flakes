-- require("telescope").load_extension("refactoring")
-- require("telescope").load_extension("yank_history")
-- require("telescope").load_extension("undo")

return {
  n = {
    -- [ "L" ] = false,
    -- [ "H" ] = false,
    [ "L" ] = { function() require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end, desc = "Next buffer" },
    [ "H" ] = { function() require("astronvim.utils.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end, desc = "Previous buffer" },
    -- [ "<leader>g" ] = { "<cmd>:Git<cr>", { desc = "Open Git interface"}, },
  },
}

