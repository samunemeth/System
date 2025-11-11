--- Auto commands ---

-- Start terminals in insert mode, and disable spelling.
vim.api.nvim_create_autocmd({ "TermOpen" }, {
	pattern = { "*" },
	command = "setlocal nospell | startinsert!",
})
