--- VSCode Settings ---

if vim.g.vscode then

  vim.keymap.set("n", "<leader>cw", "<Cmd>lua require('vscode').call('editor.action.rename')<CR>")
  vim.keymap.set("n", "=", "<Cmd>lua require('vscode').call('editor.action.formatDocument')<CR>")
  vim.keymap.set("n", "<leader>r", "<Cmd>lua require('vscode').call('workbench.action.debug.run')<CR>")
  vim.keymap.set("n", "<leader>s", "<Cmd>lua require('vscode').call('workbench.action.debug.stop')<CR>")

end
