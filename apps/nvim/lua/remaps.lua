--- Mappings ---

vim.g.mapleader = " "

-- Move lines in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Replace word under cursor
vim.keymap.set("n", "<leader>c", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Move the editor up and down in insert mode
vim.keymap.set("i", "<C-e>", "<C-o><C-e>")
vim.keymap.set("i", "<C-y>", "<C-o><C-y>")

-- Deleting into the void register
vim.keymap.set("n", "<leader>dd", '"_dd')
vim.keymap.set("n", "<leader>dw", '"_dw')
vim.keymap.set("n", "<leader>diw", '"_diw')
vim.keymap.set("v", "<leader>d", '"_d')

-- Correct spelling mistakes
vim.keymap.set({ "n", "v" }, "<C-l>", "[s1z=``")
vim.keymap.set("i", "<C-l>", "<C-g>u<Esc>[s1z=`]a<C-g>u")

-- LSP Related

-- Code completion in insert mode, hover menu otherwise.
vim.keymap.set("i", "<C-.>", "<C-x><C-o>")
vim.keymap.set({ "n", "v" }, "<C-.>", vim.lsp.buf.hover)

-- Display virtual text in a floating window.
vim.keymap.set({ "n", "v" }, "<C-,>", function()
	vim.diagnostic.open_float(0, { scope = "line", focus = false })
end)

-- Toggle inlays
vim.keymap.set("n", "<leader>i", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end)

-- Code actions with LSP
vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>c", vim.lsp.buf.rename)

-- Conventions for LSP mappings, all starting with <leader>:
--   c   -> Rename variable.
--   a   -> Action with code under the cursor.
--   r   -> Running the current file. / Evaluating all expressions.
--   e   -> Something to do with errors. Preferably explain them.
