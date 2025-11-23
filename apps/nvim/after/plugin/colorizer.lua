--- Configuration for Colorizer ---

local colorizer = safe_require("colorizer")

if colorizer then
	colorizer.setup({ user_default_options = { names = false } })
end
