--- Configuration for Nvimtree ---

local nvimtree = require("nvim-tree")

-- Settings
local function my_on_attach(bufnr)
  local api = require("nvim-tree.api")
  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end
  api.config.mappings.default_on_attach(bufnr)

  -- Keymaps
  vim.keymap.set("n", "C", api.tree.change_root_to_node, opts("CD"))
  vim.keymap.set("n", "<leader>f", "<C-w>w", opts("Change window"))
  -- vim.keymap.del('n', '<Tab>', { buffer = bufnr })
end

nvimtree.setup({
  on_attach = my_on_attach,
  filters = {
    dotfiles = true,
  },
})

-- Keymaps
vim.keymap.set("n", "<leader>f", "<cmd>NvimTreeOpen<cr>")

