--- Mappings ---

vim.g.mapleader = " "

-- Move lines in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Replace word under cursor
vim.keymap.set("n", "<leader>h", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

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
vim.keymap.set({ "i" }, "<C-l>", "<C-g>u<Esc>[s1z=`]a<C-g>u")
