--- Configuration for Colorizer ---

local colorizer = SafeRequire("colorizer")

if colorizer then
	colorizer.setup({ user_default_options = { names = false } })
end
