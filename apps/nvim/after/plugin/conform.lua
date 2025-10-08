--- Configuration for Conform ---

local conform = safe_require("conform")

if conform then

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
  },
})

vim.keymap.set("n", "=", function()
  conform.format();
end)

end
