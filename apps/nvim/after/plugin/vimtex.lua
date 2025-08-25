--- Configuration for Vimtex ---

-- Settings
vim.opt.conceallevel = 1
vim.g.tex_flavor = "latex"
vim.g.vimtex_view_method = "zathura"
vim.g.tex_conceal = "abdmg"
vim.g.vimtex_indent_lists = {}
vim.g.vimtex_mappings_enabled = true
vim.g.vimtex_imaps_enabled = 0
vim.g.vimtex_quickfix_ignore_filters = { "Underfull", "Overfull" }
vim.cmd.highlight({ "Conceal", "guifg=white" })

vim.g.vimtex_syntax_conceal = {
	["accents"] = 1,
	["ligatures"] = 1,
	["cites"] = 1,
	["fancy"] = 1,
	["spacing"] = 1,
	["greek"] = 1,
	["math_bounds"] = 1,
	["math_delimiters"] = 1,
	["math_fracs"] = 1,
	["math_super_sub"] = 1,
	["math_symbols"] = 1,
	["sections"] = 1,
	["styles"] = 1,
}
