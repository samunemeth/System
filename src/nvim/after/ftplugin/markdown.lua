--- Configuration for Markdown Files ---

local bufnr = vim.api.nvim_get_current_buf()
local buffspec = { buffer = bufnr }

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

local knap = SafeRequire("knap")

if knap then
	-- Process the document into a pdf.
	vim.keymap.set("n", "<leader>r", function()
		knap.process_once()
	end, buffspec)
end

-- This formats a markdown table using a single shell command.
-- Please keep a safe distance from this abomination.
-- Touch and comprehend at your own risk!
vim.keymap.set(
	"x",
	"<leader>t",
	[[:'<,'>! sed 's/|\([^-: ]\)/| \1/g' | tr -s ' ' | column -t -s '|' -o '|' | sed '2{s/ /-/g; s/:\(-\+\)-|/-\1:|/g}'<CR>]],
	buffspec
)
