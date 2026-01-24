--- Configuration for Tex and LaTeX Files ---

local knap = SafeRequire("knap")

if knap then
	knap.process_once()

	vim.api.nvim_create_autocmd("BufWrite", {
		buffer = 0,
		callback = function()
			knap.process_once()
		end,
	})

  -- Do a jump in Zathura to the current location.
	vim.keymap.set({ "n", "v" }, "<leader>a", function()
		knap.forward_jump()
	end)
end
