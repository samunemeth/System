--- Plugins ---

local Plug = vim.fn["plug#"]

--- Need to load before plugins ---
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

--- Plugins ---

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
Plug("karb94/neoscroll.nvim") -- For smooth scrolling

-- Change Tracking
Plug("mbbill/undotree") -- For the undo tree
Plug("tpope/vim-fugitive") -- For git

-- LSP and Syntax
Plug("nvim-treesitter/nvim-treesitter", { ["do"] = ":TSUpdate" }) -- For syntax highlighting
-- Plug("williamboman/mason.nvim") -- For installing and managing LSP servers.
-- Plug("neovim/nvim-lspconfig") -- Pre-made configurations for LSP servers.

-- AI Assistant
Plug("github/copilot.vim") -- Github Copilot

vim.call("plug#end")
