--- Configuration for Lf ---

local lf = safe_require("lf")

if lf then

--Setup
lf.setup{

  border = "curved",
  winblend = 0,

}


vim.keymap.set("n", "<leader>w", "<cmd>Lf<CR>")

end
