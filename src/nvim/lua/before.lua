--- For script that need to load before plugins ---

-- UltiSnips
-- This configuration needs to load before the plugin does.
-- NOTE: In the future, I may need to switch to LuaSnips
vim.g.UltiSnipsExpandOrJumpTrigger = "<Tab>"
vim.g.UltiSnipsJumpBackwardTrigger = "<S-Tab>"
vim.g.UltiSnipsSnippetDirectories = {
	-- WARN: This should probably not depend on the users home directory if the
	-- > configuration files are later wrapped with Neovim.
	vim.fn.expand("$HOME/.config/nvim/UltiSnips"),
}
