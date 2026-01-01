--- Configuration for Lualine ---

local lualine = SafeRequire("lualine")

if lualine then
	local function wide()
		return vim.fn.winwidth(0) > 80
	end
	lualine.setup({
		options = {
			icons_enabled = false,
			theme = "powerline",
			section_separators = { left = "", right = "" },
			component_separators = { left = "|", right = "|" },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = {
				{
					"branch",
					separator = "",
					cond = wide,
				},
				{
					"diff",
					padding = { left = 0, right = 1 },
					colored = false,
					fmt = function(text)
						if text == "" then
							return ""
						end
						return "[" .. text .. "]"
					end,
					cond = wide,
				},
			},
			lualine_c = {
				{
					"filename",
					path = 0,
					cond = wide,
				},
			},
			lualine_x = {
				{
					"encoding",
					cond = wide,
				},
				{
					"fileformat",
					cond = wide,
				},
				"filetype",
			},
			lualine_y = {
				{
					"diagnostics",
					padding = { left = 1, right = 0 },
					colored = false,
					separator = "",
					cond = wide,
				},
				{
					"lsp_status",
					padding = 1,
					symbols = {
						spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
						done = "",
					},
					show_name = true,
					cond = wide,
				},
			},
			lualine_z = {
				{
					"location",
					cond = wide,
				},
			},
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = {
				{
					"filename",
					path = 0,
					cond = wide,
				},
			},
			lualine_x = { "filetype" },
			lualine_y = {},
			lualine_z = {},
		},
		tabline = {},
		winbar = {},
		inactive_winbar = {},
		extensions = {},
	})
end
