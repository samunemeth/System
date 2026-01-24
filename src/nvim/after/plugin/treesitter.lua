--- Configuration for Treesitter ---

local treesitter = SafeRequire("nvim-treesitter.configs")

if treesitter then
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
