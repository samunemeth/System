--- Configuration for Nabla ---

local nabla = safe_require("nabla")

if nabla then
	vim.keymap.set("n", "<leader>a", function()
		nabla.popup({ border = "rounded" })
	end)
end
