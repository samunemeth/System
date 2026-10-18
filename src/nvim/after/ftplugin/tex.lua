--- Configuration for Tex and LaTeX Files ---

local knap = SafeRequire("knap")

local bufnr = vim.api.nvim_get_current_buf()
local buffspec = { buffer = bufnr }

if knap then
	knap.process_once()

	vim.api.nvim_create_autocmd("BufWrite", {
		buffer = 0,
		callback = function()
			knap.process_once()
			-- TODO: Do we really want to jump every time?
			-- > Is there a way to know then the compile is done, not just guess?
			vim.defer_fn(function()
				knap.forward_jump()
			end, 500)
		end,
	})

	-- Do a jump in Zathura to the current location.
	vim.keymap.set({ "n", "v" }, "<leader>a", function()
		knap.forward_jump()
	end)

  -- Open the table of contents on the side.
	vim.keymap.set("n", "<leader>t", "<cmd>VimtexTocToggle<CR>", buffspec)
end
