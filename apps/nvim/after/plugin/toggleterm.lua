--- Configuration for Toggleterm ---

local toggleterm = require("toggleterm")

-- Setup

toggleterm.setup{
  open_mapping = "<c-t>",
  insert_mappings = false,
  terminal_mappings = true,
  direction = "float",
  float_opts = {
    border = "curved",
    title_pos = "center",
  },
}

