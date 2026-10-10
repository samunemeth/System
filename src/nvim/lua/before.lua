-- For script that need to load before plugins.

--- UltiSnips ---
vim.g.UltiSnipsExpandOrJumpTrigger = "<Tab>"
vim.g.UltiSnipsJumpBackwardTrigger = "<S-Tab>"
vim.g.UltiSnipsSnippetDirectories = { "UltiSnips" }
vim.g.UltiSnipsSnippetsDir = "/tmp"
vim.api.nvim_create_user_command("UltiSnipsReload", function()
  vim.cmd("call UltiSnips#RefreshSnippets()")
end, {})
