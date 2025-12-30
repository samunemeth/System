--- Configuration for Nix Files ---

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = false

local bufnr = vim.api.nvim_get_current_buf()
local buffspec = { buffer = bufnr }

vim.lsp.config["nixd"] = {
	cmd = { "nixd" },
	filetypes = { "nix" },
	root_markers = { "flake.nix", ".git" },
}

vim.lsp.enable("nixd")

-- vim.keymap.set("n", "<leader>a", function()
-- 	vim.lsp.buf.code_action()
-- end, buffspec)
--
-- vim.keymap.set("n", "<leader>c", function()
-- 	vim.lsp.buf.rename()
-- end, buffspec)
