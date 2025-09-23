--- VSCode Settings ---

if vim.g.vscode then

  vim.keymap.set("n", "<leader>cw", "<Cmd>lua require('vscode').call('editor.action.rename')<CR>")
  vim.keymap.set("n", "=", "<Cmd>lua require('vscode').call('editor.action.formatDocument')<CR>")

end
