--- Configuration for Gitsigns ---

local gitsigns = SafeRequire("gitsigns")

if gitsigns then
	gitsigns.setup({
		signs = {
			add = { text = "┃" },
			change = { text = "┃" },
			delete = { text = "▁", show_count = true },
			topdelete = { text = "▔", show_count = true },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
    signcolumn = false,
		numhl = false,
		count_chars = {
			[1] = "₁",
			[2] = "₂",
			[3] = "₃",
			[4] = "₄",
			[5] = "₅",
			[6] = "₆",
			[7] = "₇",
      [8] = "₈",
      [9] = "₉",
      ["+"] = "₊",
		},
	})

  -- Toggle the column that shows the changes and the coloring on the left.
  vim.keymap.set("n", "<leader>s", function()
    gitsigns.toggle_signs()
    gitsigns.toggle_numhl()
  end)
end
