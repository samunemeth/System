--- Configuration for Fidget ---

local fidget = safe_require("fidget")

-- NOTE: Can be used for notifications.
-- BUG: Does not work with Haskell language server.

if fidget then
	fidget.setup()
end
