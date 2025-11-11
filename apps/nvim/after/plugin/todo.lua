--- Configuration for ToDo ---

local todo = safe_require("todo-comments")

if todo then
	todo.setup({
		signs = false,
		highlight = {
			before = "",
			keyword = "bg",
			after = "fg",
			multiline_pattern = "^.*>.*$",
		},
		gui_style = {
			fg = "ITALIC",
			bg = "BOLDITALIC",
		},
		colors = {
			hint = { "Comment" },
		},
	})
end
