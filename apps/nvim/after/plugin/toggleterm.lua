--- Configuration for Toggleterm ---

local toggleterm = safe_require("toggleterm")

if toggleterm then

-- Setup

toggleterm.setup{
  open_mapping = "<c-s>",
  insert_mappings = false,
  terminal_mappings = true,
  direction = "float",
  float_opts = {
    border = "curved",
    title_pos = "center",
    width = function(term)
      if vim.o.columns > 160 then
        return vim.o.columns - 110
      end
    end,
    col = function(term)
      if vim.o.columns > 160 then
        return 100
      end
    end,
  },
  auto_scroll = true,
}

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
end
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

vim.keymap.set("n", "<leader>j", "<cmd>2TermExec cmd=\"java %:p\" name=\"Java Execution\"<CR>")


end
