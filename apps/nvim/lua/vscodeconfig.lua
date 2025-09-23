--- VSCode Settings ---

if vim.g.vscode then

  local vscode = require('vscode')
  
  vim.keymap.set("n", "<leader>cw", vscode.action("editor.action.rename"))

end
