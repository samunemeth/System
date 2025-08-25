--- Mappings ---

vim.g.mapleader = " "

-- Open a terminal window to the side or to the bottom
-- vim.keymap.set("n", "<leader>tv", "<C-w>v<C-w>w<cmd>ter<cr>")
-- vim.keymap.set("n", "<leader>th", "<C-w>s<C-w>w<cmd>ter<cr>")

vim.keymap.set("n", "<leader>t", function()
  local cwd = vim.fn.getcwd()
  vim.ui.input({prompt=cwd .. "$ "}, function(c) 
      if c and c~="" then 
        local bufnr = vim.api.nvim_create_buf(false, true) 
        vim.cmd("noswapfile vnew") 
        vim.api.nvim_win_set_buf(0, bufnr)
        vim.bo.buftype = "nofile"
        vim.bo.bufhidden = "wipe"
        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.systemlist(c))
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', ':bd!<CR>', { noremap = true, silent = true })
      end 
  end) 
end)

-- Move lines in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Replace word under cursor
vim.keymap.set("n", "<leader>h", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Move the editor up and down in insert mode
vim.keymap.set("i", "<C-e>", "<C-o><C-e>")
vim.keymap.set("i", "<C-y>", "<C-o><C-y>")

-- Deleting into the void register
vim.keymap.set("n", "<leader>dd", "\"_dd")
vim.keymap.set("n", "<leader>dw", "\"_dw")
vim.keymap.set("n", "<leader>diw", "\"_diw")
vim.keymap.set("v", "<leader>d", "\"_d")

-- Correct spelling mistakes
vim.keymap.set({"n", "v"}, "<C-l>", "[s1z=``")
vim.keymap.set({"i"}, "<C-l>", "<C-g>u<Esc>[s1z=`]a<C-g>u")

-- New lines without insert mode
vim.keymap.set('n', '<CR>', 'm`o<Esc>``')
vim.keymap.set('n', '<S-CR>', 'm`O<Esc>``')
