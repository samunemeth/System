--- Configuration for Conform ---

local conform = safe_require("conform")

if conform then
	require("conform").setup({
		formatters_by_ft = {
			lua = { "stylua" },
			nix = { "nixfmt" },
			sh = { "beautysh" },
		},
	})

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

vim.keymap.set("n", "<leader>=", function()
	vim.fn.jobstart("treefmt", {
		on_exit = function(job_id, exit_code)
			if exit_code == 0 then
				vim.cmd("checktime")
				print("Formatted all saved files.")
			else
				print("There has been an error whlie formatting files in the project. Exit code: " .. exit_code)
			end
		end,
	})
end)
