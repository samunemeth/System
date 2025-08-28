--- Configuration for Treesitter ---

local treesitter = safe_require("nvim-treesitter.configs")

if treesitter then

-- Settings
treesitter.setup({
  ensure_installed = { "javascript", "html", "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    disable = { "latex" },
    additional_vim_regex_highlighting = false,
  },
})

end
