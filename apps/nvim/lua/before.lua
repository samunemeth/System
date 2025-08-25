--- For script that need to load before plugins ---

-- UltiSnips
-- This configuration needs to load before the plugin does.
-- In the future, I may need to switch to LuaSnips
vim.g.UltiSnipsExpandOrJumpTrigger = "<Tab>"
vim.g.UltiSnipsJumpBackwardTrigger = "<S-Tab>"
vim.g.UltiSnipsSnippetDirectories = {
	vim.fn.expand("$HOME/.config/nvim/UltiSnips"),
}
