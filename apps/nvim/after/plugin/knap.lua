--- Configuration for Knap ---

local knap = safe_require("knap")

if knap then
	vim.g.knap_settings = {

		-- Options for compiling and previewing LaTeX.
		textopdfviewerlaunch = "zathura "
			.. "--synctex-editor-command 'nvim --headless -es --cmd "
			.. "\"lua require('\"'\"'knaphelper'\"'\"').relayjump("
			.. "'\"'\"'%servername%'\"'\"','\"'\"'%{input}'\"'\"',%{line},0)\"' "
			.. "%outputfile%",
		textopdfviewerrefresh = "none",
		textopdfforwardjump = "zathura " .. "--synctex-forward=%line%:%column%:%srcfile% %outputfile%",
		textopdf = "pdflatex -synctex=1 " .. '-jobname "$(basename -s .pdf %outputfile%)" -halt-on-error',
		textopdfbufferasstdin = true,

		-- Options for compiling and previewing markdown.
		mdoutputext = "pdf",
		mdtopdf = "pandoc %docroot% -s -f markdown -t pdf -V papersize:a4 -V geometry:margin=1.5in -o %outputfile%",
		mdtopdfviewerlaunch = "zathura %outputfile%",
		mdtopdfviewerrefresh = "none",
	}

	-- Start compilation when a LaTeX file is opened
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufWrite" }, {
		pattern = { "main.tex" },
		callback = function()
			knap.process_once()
		end,
	})

	-- Remaps to useful commands
	vim.keymap.set({ "n", "v" }, "<leader>x", function()
		knap.close_viewer()
	end)
	vim.keymap.set({ "n", "v" }, "<leader>a", function()
		knap.toggle_autopreviewing()
	end)
	vim.keymap.set({ "n", "v" }, "<leader>y", function()
		knap.forward_jump()
	end)
	vim.keymap.set({ "n", "v" }, "<leader>p", function()
		knap.process_once()
	end)

	-- Function that tries to open a pdf with the same file name.
	vim.keymap.set({ "n", "v" }, "<leader>o", function(opts)
		local to_open = vim.fn.expand("%:p:r") .. ".pdf"
		if vim.fn.filereadable(to_open) == 1 then
			print("Opened Zathura.")
			vim.fn.jobstart("zathura " .. to_open)
		else
			print("PDF version not found!")
		end
	end)
end
