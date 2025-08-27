--- Configuration for Lf ---

local lf = require("lf")

--Setup
lf.setup{

  border = "curved",
  winblend = 0,

}


vim.keymap.set("n", "<leader>w", "<cmd>Lf<CR>")
