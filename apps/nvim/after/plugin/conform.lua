--- Configuration for Conform ---

local conform = safe_require("conform")

if conform then
	conform.setup({
		formatters_by_ft = {
			lua = { "stylua" },
			nix = { "nixfmt" },
			sh = { "beautysh" },
			rust = { "rustfmt" },
			haskell = { "ormolu" },
			tex = { "tex-fmt" },
			python = { "autopep8" },
		},
	})

	-- BUG: Overwriting the setting for VSCode. Add a way to check if already set.
	vim.keymap.set("n", "=", function()
		conform.format({ async = true }, function(err, did_edit)
			if err then
				print(err)
			else
				if did_edit then
					print("Formatted file.")
				else
					print("Nothing to format.")
				end
			end
		end)
	end)

end
