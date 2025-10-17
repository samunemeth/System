--- Configuration for Vim-fugitive ---

-- Keymaps
vim.keymap.set("n", "<leader>g", vim.cmd.Git)
vim.keymap.set("n", "<leader>c", '<cmd>Git log --pretty=format:"%h %as %an: %s"<cr>')
