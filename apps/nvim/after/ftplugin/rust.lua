local bufnr = vim.api.nvim_get_current_buf()

--- Completion ---

vim.o.completeopt = "fuzzy,menuone,noinsert"
vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

vim.keymap.set("i", ".", function()
	local col = vim.fn.col(".") - 1
	local line = vim.api.nvim_get_current_line()
	local prev = (col >= 1) and line:sub(col, col) or ""
	if prev == "." then
	  return "."
	end
	return vim.api.nvim_replace_termcodes(".<C-g>u<C-x><C-o>", true, false, true)
end, { expr = true, noremap = true, buffer = bufnr })

-- when typing ":" in insert mode, if previous char is ":" insert and open omni-completion
vim.keymap.set("i", ":", function()
	local col = vim.fn.col(".") - 1
	local line = vim.api.nvim_get_current_line()
	local prev = (col >= 1) and line:sub(col, col) or ""
	if prev == ":" then
		return vim.api.nvim_replace_termcodes(":<C-g>u<C-x><C-o>", true, false, true)
	end
	return ":"
end, { expr = true, noremap = true, buffer = bufnr })

--- Pop-up Windows ---

-- Ensure all uses of open_floating_preview default to rounded
do
	local orig = vim.lsp.util.open_floating_preview
	vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig(contents, syntax, opts, ...)
	end
end

-- Make the pop-ups have a consistent color.
vim.cmd([[
  highlight! link FloatBorder TelescopeBorder
  highlight! link NormalFloat TelescopeNormal
]])

--- Inlays and Diagnostics ---

vim.lsp.inlay_hint.enable(true)
vim.diagnostic.config({
	virtual_text = {
		spacing = 4,
		prefix = function(diagnostic)
			local sev = diagnostic.severity
			if sev == vim.diagnostic.severity.ERROR then
				return ""
			end
			return ""
		end,
	},
	signs = false,
	underline = true,
	severity_sort = true,
})

--- Remaps ---

-- Completion suggestions.
vim.keymap.set("i", "<C-.>", "<C-x><C-o>", { noremap = true, silent = true })

-- Actions with code.
vim.keymap.set("n", "<leader>a", function()
	vim.cmd.RustLsp("codeAction")
end, { silent = true, buffer = bufnr })

-- Hover menu.
vim.keymap.set("n", "<C-.>", function()
	vim.cmd.RustLsp({ "hover", "actions" })
end, { silent = true, buffer = bufnr })

-- Detailed errors.
vim.keymap.set("n", "<leader>e", function()
	vim.cmd.RustLsp({ "renderDiagnostic", "cycle" })
end, { silent = true, buffer = bufnr })

-- Run program.
vim.keymap.set("n", "<leader>r", function()
	vim.cmd.RustLsp({ "runnables", bang = true })
end, { silent = true, buffer = bufnr })

-- Toggle inlays.
vim.keymap.set("n", "<leader>i", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { silent = true, buffer = bufnr })
