--- Configuration for SOPS ---

local sops = safe_require("sops")

if sops then
	sops.setup({
		skip_explicit_keys = true,
	})
end
