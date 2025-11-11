--- Configuration for Treesitter ---

local treesitter = safe_require("nvim-treesitter.configs")

if treesitter then
	-- Settings
	treesitter.setup({
		parser_install_dir = "/dev/null",
		sync_install = false,
		auto_install = false,
		highlight = {
			enable = true,
			disable = { "latex" },
			additional_vim_regex_highlighting = false,
		},
	})
end
