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
}

end
