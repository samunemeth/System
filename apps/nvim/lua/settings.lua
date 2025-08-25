--- Settings ---

-- Line numbering configuration
vim.opt.number = true
vim.opt.relativenumber = true

-- Indenting
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- No backups
vim.opt.swapfile = false
vim.opt.backup = false

-- Unod
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Colors
vim.opt.termguicolors = true

-- Scrolling
vim.opt.scrolloff = 8

-- Spell configuration
vim.opt.spell = true
vim.opt.spelllang = "hu,en"
vim.opt.spellcapcheck = ""

-- Clipboard configuration
vim.opt.clipboard = "unnamedplus"
if vim.fn.has('wsl') == 1 then
  vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('Yank', { clear = true }),
    callback = function()
      vim.fn.system('clip.exe', vim.fn.getreg('"'))
    end,
  })
end

-- Panel behaviour
vim.opt.splitbelow = true

-- Show color column
vim.opt.colorcolumn = "80"

-- Auto reload on external change
vim.opt.autoread = true
