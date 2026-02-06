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

-- Undo
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Colors
vim.opt.termguicolors = true

-- Scrolling
vim.opt.scrolloff = 12

-- Spell Configuration

vim.opt.spell = false

local src_spellfile = vim.fs.joinpath(vim.fn.stdpath("config"), "spell", "en.utf-8.add")
local usr_spelldir = vim.fs.joinpath(vim.fn.stdpath("state"), "spell")
local usr_spellfile = vim.fs.joinpath(usr_spelldir, "en.utf-8.add")
local spl_spellfile = usr_spellfile .. ".spl"

local src_mtime = vim.fn.getftime(src_spellfile)
local usr_mtime = vim.fn.getftime(usr_spellfile)
local spl_mtime = vim.fn.getftime(spl_spellfile)

vim.fn.mkdir(usr_spelldir, "p")

if src_mtime > usr_mtime then
	vim.fn.writefile(vim.fn.readfile(src_spellfile), usr_spellfile)
	usr_mtime = vim.fn.getftime(usr_spellfile)
end

if usr_mtime > spl_mtime then
	vim.cmd("silent! mkspell! " .. spl_spellfile .. " " .. usr_spellfile)
end

vim.opt.spell = true
vim.opt.spellfile = usr_spellfile
vim.opt.spelllang = { "en" }
vim.opt.spellcapcheck = ""

-- Clipboard configuration
vim.opt.clipboard = "unnamedplus"
if vim.fn.has("wsl") == 1 then
	vim.api.nvim_create_autocmd("TextYankPost", {
		group = vim.api.nvim_create_augroup("Yank", { clear = true }),
		callback = function()
			vim.fn.system("clip.exe", vim.fn.getreg('"'))
		end,
	})
end

-- Disable bold and italic in tmux
if vim.env.TERM == "tmux-256color" then
  vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = function()
      for _, group in ipairs(vim.fn.getcompletion("", "highlight")) do
        local hl = vim.api.nvim_get_hl(0, { name = group })
        if hl.bold or hl.italic then
          hl.bold = nil
          hl.italic = nil
          vim.api.nvim_set_hl(0, group, hl)
        end
      end
    end,
  })
end

-- Panel behaviour
vim.opt.splitbelow = true

-- Show color column
vim.opt.colorcolumn = "80"
-- vim.opt.textwidth = 80

-- Auto reload on external change
vim.opt.autoread = true

-- Disable mouse input.
vim.opt.mouse = ""

-- Completion settings.
vim.o.completeopt = "fuzzy,menuone,noinsert"

-- Ensure all LSP floating windows are rounded.
do
	local orig = vim.lsp.util.open_floating_preview
	vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig(contents, syntax, opts, ...)
	end
end

-- Make floating windows have a consistent color.
vim.cmd([[
  highlight! link FloatBorder TelescopeBorder
  highlight! link NormalFloat TelescopeNormal
]])

-- Disable inlay hints by default.
vim.lsp.inlay_hint.enable(false)

-- Configure diagnostic text appearing at the end of lines.
vim.diagnostic.config({

	virtual_text = {

		-- Remove extra white space inside the messages.
		format = function(d)
			local msg = d.message:gsub("\r", ""):gsub("\n", " "):gsub("\t", " ")
			msg = msg:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
			return msg
		end,

		prefix = "",
		spacing = 1,
	},

	signs = false,
	underline = true,
	severity_sort = true,
})
