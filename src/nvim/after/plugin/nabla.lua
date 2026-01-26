--- Configuration for Nabla ---

local nabla = SafeRequire("nabla")

if nabla then
	vim.keymap.set("n", "<leader>n", function()
		nabla.popup({ border = "rounded" })
	end)
end
