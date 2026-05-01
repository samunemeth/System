--- Configuration for Java ---

-- Completion
local bufnr = vim.api.nvim_get_current_buf()

-- Open auto completion on '.'
vim.keymap.set("i", ".", function()
	local col = vim.fn.col(".") - 1
	local line = vim.api.nvim_get_current_line()
	local prev = (col >= 1) and line:sub(col, col) or ""
	if prev == "." then
		return "."
	end
	return vim.api.nvim_replace_termcodes(".<C-g>u<C-x><C-o>", true, false, true)
end, { expr = true, noremap = true, buffer = bufnr })

-- Checkstyle
local checkstyle = SafeRequire("checkstyle-integration")

if checkstyle then
	local function find_checkstyle()
		local root = vim.fn.getcwd()

    -- Check the root directory for the checkstyle file.
		local p1 = root .. "/checkstyle.xml"
		if vim.loop.fs_stat(p1) then
			return p1
		end

		-- Check one directory deeper.
		local matches = vim.fn.glob(root .. "/*/checkstyle.xml", false, true)
		if matches and #matches > 0 then
			return matches[1]
		end

		return nil
	end

	checkstyle.setup({
		checkstyle_file = find_checkstyle(),
		checkstyle_on_write = true,
		force_severity = "WARN",
	})
end
