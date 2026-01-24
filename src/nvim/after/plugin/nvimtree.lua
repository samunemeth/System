--- Configuration for Nvimtree ---

local nvimtree = SafeRequire("nvim-tree")

if nvimtree then
	-- Settings
	local function my_on_attach(bufnr)
		local api = SafeRequire("nvim-tree.api")
		local function opts(desc)
			return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
		end
		api.config.mappings.default_on_attach(bufnr)

		-- Keymaps
		vim.keymap.set("n", "C", api.tree.change_root_to_node, opts("CD"))
		vim.keymap.set("n", "<leader>f", "<C-w>w", opts("Change window"))
	end

	nvimtree.setup({
		on_attach = my_on_attach,
		filters = {
			dotfiles = true,
		},
	})

	-- Keymaps
	vim.keymap.set("n", "<leader>f", "<cmd>NvimTreeOpen<cr>")
end
