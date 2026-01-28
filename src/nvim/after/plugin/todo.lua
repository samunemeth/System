--- Configuration for ToDo ---

local todo = SafeRequire("todo-comments")

-- TODO: Change to color of TODO messages to a darker blue.
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
