--- Configuration for Knap ---

local knap = SafeRequire("knap")

if knap then
	vim.g.knap_settings = {

		-- Options for compiling and previewing LaTeX.
		textopdfviewerlaunch = [[zathura -x "nvim --headless -es --cmd \"lua require('knaphelper').relayjump('%servername%', '%{input}', %{line}, 0)\"" %outputfile%]],
		textopdfviewerrefresh = "none",
		textopdfforwardjump = [[zathura --fork --synctex-forward=%line%:%column%:%srcfile% %outputfile%]],
		textopdf = "pdflatex -interaction=batchmode -halt-on-error -synctex=1 %docroot%",

		-- Options for compiling and previewing markdown.
		mdoutputext = "pdf",
		mdtopdf = "pandoc %docroot% -s -f markdown -t pdf -V papersize:a4 -V geometry:margin=1.5in -o %outputfile%",
		mdtopdfviewerlaunch = "zathura %outputfile%",
		mdtopdfviewerrefresh = "none",
	}

	-- Function that tries to open a pdf with the same file name.
	vim.keymap.set("n", "<leader>o", function(opts)
		local to_open = vim.fn.expand("%:p:r") .. ".pdf"
		if vim.fn.filereadable(to_open) == 1 then
			print("Opened Zathura.")
			vim.fn.jobstart("zathura " .. to_open)
		else
			print("PDF version not found!")
		end
	end)
end
