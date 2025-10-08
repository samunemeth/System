--- Plugins ---

local Plug = vim.fn["plug#"]

-- All packages used are imported here.
-- Any package without a comment after it is a requirement of the next package.
-- Packages are grouped based on functionality.

vim.call("plug#begin")

-- LaTeX related
Plug("lervag/vimtex") -- For compiling latex
Plug("frabjous/knap") -- Live latex compile
Plug("jbyuki/nabla.nvim") -- For equation preview in the editor.
Plug("SirVer/ultisnips") -- For creating snippets

-- File Management
Plug("nvim-tree/nvim-tree.lua") -- For file tree
Plug("nvim-lua/plenary.nvim")
Plug("nvim-telescope/telescope.nvim", { ["tag"] = "0.1.8" }) -- For fuzzy finding

-- Visuals
Plug("itchyny/lightline.vim") -- For the fancy status bar

-- Change Tracking
Plug("mbbill/undotree") -- For the undo tree
Plug("tpope/vim-fugitive") -- For git

-- LSP and Syntax
Plug("nvim-treesitter/nvim-treesitter", { ["do"] = ":TSUpdate" }) -- For syntax highlighting
Plug("stevearc/conform.nvim")

vim.call("plug#end")

-- Check for missing plugins, and install them automatically.
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.exists("g:plugs") == 1 then
			for _, plug in pairs(vim.g.plugs) do
				if vim.fn.isdirectory(plug.dir) == 0 then
					vim.cmd("echo 'Installing plugins, please restart after!' | PlugInstall --sync | qa")
					break
				end
			end
		end
	end,
	group = vim.api.nvim_create_augroup("AutoPlugInstall", { clear = true }),
})

function safe_require(module)
	local ok, mod = pcall(require, module)
	return ok and mod or nil
end
