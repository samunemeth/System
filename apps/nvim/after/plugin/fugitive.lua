--- Configuration for Vim-fugitive ---

-- TODO: Is there a way to detect weather the plugin is present?

-- Keymaps
vim.keymap.set("n", "<leader>g", vim.cmd.Git)
vim.keymap.set("n", "<leader>c", '<cmd>Git log --pretty=format:"%h %as %an: %s"<cr>')
