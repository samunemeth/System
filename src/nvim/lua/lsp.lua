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

-- Lua
vim.lsp.config["lua_ls"] = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".emmyrc.json",
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		"stylua.toml",
		"selene.toml",
		"selene.yml",
		".git",
	},
	settings = {
		Lua = {
			codeLens = { enable = true },
			hint = { enable = true, semicolon = "Disable" },
		},
	},
	on_init = function(client)
		-- Check if the Lua files are related to Neovim.
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath("config")
				and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end
		-- Make the server aware of Neovim runtime files
		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				version = "LuaJIT",
				path = {
					"lua/?.lua",
					"lua/?/init.lua",
				},
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
				},
			},
		})
	end,
}
vim.lsp.enable("lua_ls")

-- Grammar
local grammar_language_id_mapping = {
	bib = "bibtex",
	pandoc = "markdown",
	plaintex = "tex",
	rnoweb = "rsweave",
	rst = "restructuredtext",
	tex = "latex",
	text = "plaintext",
}

vim.lsp.config["ltex_plus"] = {
	cmd = { "ltex-ls-plus" },
	filetypes = {
		"asciidoc",
		"bib",
		"context",
		"gitcommit",
		"html",
		"markdown",
		"org",
		"pandoc",
		"plaintex",
		"quarto",
		"mail",
		"mdx",
		"rmd",
		"rnoweb",
		"rst",
		"tex",
		"text",
		"typst",
		"xhtml",
	},
	root_markers = { ".git" },
	get_language_id = function(_, filetype)
		return grammar_language_id_mapping[filetype] or filetype
	end,
	settings = {
		ltex = {
      language = "en-GB",
      checkFrequency = "save",
      disabledRules = {
        ["en-GB"] = { "MORFOLOGIK_RULE_EN_GB" },
        ["en-US"] = { "MORFOLOGIK_RULE_EN_US" },
      },
      enabledRules = {
        ["en-GB"] = { "COMMA_COMPOUND_SENTENCE", "COMMA_COMPOUND_SENTENCE_2" },
        ["en-US"] = { "COMMA_COMPOUND_SENTENCE", "COMMA_COMPOUND_SENTENCE_2" },
      },
      additionalRules = {
        enablePickyRules = true,
      },
      diagnosticSeverity = "warning",
			enabled = {
				"asciidoc",
				"bib",
				"context",
				"gitcommit",
				"html",
				"markdown",
				"org",
				"pandoc",
				"plaintex",
				"quarto",
				"mail",
				"mdx",
				"rmd",
				"rnoweb",
				"rst",
				"tex",
				"latex",
				"text",
				"typst",
				"xhtml",
			},
		},
	},
}
vim.lsp.enable("ltex_plus")
