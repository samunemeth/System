--- Configuration for Python Files ---

local bufnr = vim.api.nvim_get_current_buf()
local buffspec = { buffer = bufnr }

vim.lsp.config["pylsp"] = {
	cmd = { "pylsp" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		".git",
	},
	settings = {
		pylsp = {
			plugins = {
				rope = { enabled = true },
				pyflakes = { enabled = true },
				autopep8 = { enabled = true },
			},
		},
	},
}

vim.lsp.enable("pylsp")

vim.keymap.set("n", "<leader>a", function()
	vim.lsp.buf.code_action()
end, buffspec)

vim.keymap.set("n", "<leader>c", function()
	vim.lsp.buf.rename()
end, buffspec)
