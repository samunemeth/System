--- Configuration for Telescope ---

local telescope = require("telescope")
local builtin = require("telescope.builtin")

-- Settings
telescope.setup{
	defaults = { file_ignore_patterns = {

		-- General ignores
		"%.pdf",

		-- File ignores for latex projects
		"main.pdf", "main.aux", "main.fdb_latexmk", "main.fls", "main.log", "main.pdf", "main.synctex.gz", "main.toc", "main.out",

	} },
	pickers = { find_files = { hidden = false } }
} 

-- Keymaps
vim.keymap.set("n", "<leader><leader>", builtin.find_files, {})
vim.keymap.set("n", "<leader>/", builtin.live_grep, {})
