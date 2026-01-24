--- Configuration for Rust Files ---

-- Completion
local bufnr = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
local buffspec = { buffer = bufnr }

-- Open auto completion on '.'
vim.keymap.set("i", ".", function()
	local col = vim.fn.col(".") - 1
	local line = vim.api.nvim_get_current_line()
	local prev = (col >= 1) and line:sub(col, col) or ""
	if prev == "." then
		return "."
	end
	return vim.api.nvim_replace_termcodes(".<C-g>u<C-x><C-o>", true, false, true)
end, { expr = true, noremap = true, buffer = bufnr })

-- Open auto completion on '::'
vim.keymap.set("i", ":", function()
	local col = vim.fn.col(".") - 1
	local line = vim.api.nvim_get_current_line()
	local prev = (col >= 1) and line:sub(col, col) or ""
	if prev == ":" then
		return vim.api.nvim_replace_termcodes(":<C-g>u<C-x><C-o>", true, false, true)
	end
	return ":"
end, { expr = true, noremap = true, buffer = bufnr })

-- Remaps

-- Actions with code
vim.keymap.set("n", "<leader>a", function()
	vim.cmd.RustLsp("codeAction")
end, buffspec)

-- Hover menu.
vim.keymap.set("n", "<C-.>", function()
	vim.cmd.RustLsp({ "hover", "actions" })
end, buffspec)

-- Detailed errors.
vim.keymap.set("n", "<leader>e", function()
	vim.cmd.RustLsp({ "renderDiagnostic", "cycle" })
end, buffspec)

-- Run program.
vim.keymap.set("n", "<leader>r", function()
	vim.cmd.RustLsp({ "runnables", bang = true })
end, buffspec)
