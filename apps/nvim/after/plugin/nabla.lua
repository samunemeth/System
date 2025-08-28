--- Configuration for Nabla ---

local nabla = safe_require("nabla")

if nabla then

-- Keymaps
vim.keymap.set("n", "<leader>e", nabla.popup)


end
