--- Configuration for Haskell Files ---

local ht = safe_require("haskell-tools")
local bufnr = vim.api.nvim_get_current_buf()
local opts = { noremap = true, silent = true, buffer = bufnr }

vim.keymap.set("n", "<C-.>", vim.lsp.buf.hover, opts)
vim.keymap.set("n", "<space>e", ht.lsp.buf_eval_all, opts)
vim.keymap.set('n', '<space>r', vim.lsp.codelens.run, opts)
