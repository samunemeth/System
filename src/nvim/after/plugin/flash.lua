--- Configuration for Flash ---

local flash = SafeRequire("flash")

if flash then
	flash.setup({})

	-- Enable in search mode. I'm unsure how the labels are determined.
	flash.toggle(true)

	-- Worth a try for now, but will probably melt my brain.
	vim.keymap.set({ "n", "x", "o" }, "'", function()
		flash.jump()
	end)
end
