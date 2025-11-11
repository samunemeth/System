--- Configuration for ToDo ---

local todo = safe_require("todo-comments")

if todo then
	todo.setup({
		signs = false,
		highlight = {
			before = "fg",
			keyword = "bg",
			after = "fg",
		},
		gui_style = {
			fg = "ITALIC",
			bg = "BOLDITALIC",
		},
		colors = {
			hint = { "String" },
		},
	})
end
