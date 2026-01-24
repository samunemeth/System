--- VSCode Settings ---

-- TODO: These are all conflicting with stuff...
-- > Would be nice to override them if needed.
-- > There is cleanup needed here.

-- Only apply these settings if inside VSCode.
if vim.g.vscode then
	-- Refactor and format.
	vim.keymap.set("n", "<leader>c", "<Cmd>lua require('vscode').call('editor.action.rename')<CR>")
	vim.keymap.set("n", "=", "<Cmd>lua require('vscode').call('editor.action.formatDocument')<CR>")

	-- Run and stop file.
	vim.keymap.set("n", "<leader>r", "<Cmd>lua require('vscode').call('workbench.action.debug.run')<CR>")
	vim.keymap.set("n", "<leader>s", "<Cmd>lua require('vscode').call('workbench.action.debug.stop')<CR>")
end
