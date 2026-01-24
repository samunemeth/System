--- Configuration for Haskell Files ---

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

local ht = SafeRequire("haskell-tools")
local bufnr = vim.api.nvim_get_current_buf()
local buffspec = { buffer = bufnr }

if ht then
	vim.keymap.set("n", "<space>r", ht.lsp.buf_eval_all, buffspec)
	vim.keymap.set("n", "<space>a", vim.lsp.codelens.run, buffspec)
end
