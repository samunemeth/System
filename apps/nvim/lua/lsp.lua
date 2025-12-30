--- LSP Server Settings ---

-- Python
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
				autopep8 = { enabled = false },
				pycodestyle = { enabled = false },
			},
		},
	},
}
vim.lsp.enable("pylsp")

-- Nix
local hostname = vim.loop.os_gethostname()
vim.lsp.config["nixd"] = {
	cmd = { "nixd" },
	filetypes = { "nix" },
	root_markers = { "flake.nix", ".git" },
	settings = {
		nixd = {
      -- Some magic such that the options are recognised.
			options = {
				nixos = {
					expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.'
						.. hostname
						.. ".options",
				},
				home_manager = {
					expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.'
						.. hostname
						.. ".options.home-manager.users.type.getSubOptions []",
				},
			},
			diagnostic = {
				suppress = {
          -- Turn off unused argument warnings.
					"sema-unused-def-lambda-witharg-formal",
					"sema-unused-def-lambda-noarg-formal",
					"sema-unused-def-lambda-witharg-arg",
				},
			},
		},
	},
}
vim.lsp.enable("nixd")
