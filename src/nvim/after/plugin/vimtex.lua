--- Configuration for Vimtex ---

-- TODO: Is there a way to detect weather the plugin is present?
-- TODO: Add a way to open table of contents with `:VimtexTocOpen`

-- Settings
vim.opt.conceallevel = 1
vim.g.tex_flavor = "latex"
vim.g.vimtex_view_method = "zathura"
vim.g.tex_conceal = "abdmg" -- NOTE: This is probably not needed?
vim.g.vimtex_indent_lists = {}
vim.g.vimtex_mappings_enabled = true
vim.g.vimtex_imaps_enabled = 0 -- NOTE: Why is this 0 if the above is true?

-- Sterilise the plugin so that it does not complain if latexmk is
-- not available; it is not used.
vim.g.vimtex_compiler_method = "generic"
vim.g.vimtex_compiler_generic = { ["command"] = ":" }

-- Color and graphical options.
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
