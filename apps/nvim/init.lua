--- Central configuration ---

function safe_require(module)
	local ok, mod = pcall(require, module)
	return ok and mod or nil
end

-- Load modules
require("settings")
require("remaps")
require("autocommands")
require("before")
require("code")
require("lsp")
