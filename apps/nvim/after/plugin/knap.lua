--- Configuration for Knap --- 
local knap = require("knap")

-- Knap settings
local gknapsettings = {
    textopdfviewerlaunch = "zathura " ..
        "--synctex-editor-command 'nvim --headless -es --cmd " ..
        "\"lua require('\"'\"'knaphelper'\"'\"').relayjump(" ..
        "'\"'\"'%servername%'\"'\"','\"'\"'%{input}'\"'\"',%{line},0)\"' " ..
        "%outputfile%",
    textopdfviewerrefresh = "none",
    textopdfforwardjump = "zathura " .. 
        "--synctex-forward=%line%:%column%:%srcfile% %outputfile%",
    textopdf = "pdflatex -synctex=1 " ..
        "-jobname \"$(basename -s .pdf %outputfile%)\" -halt-on-error",
    textopdfbufferasstdin = true,
}
vim.g.knap_settings = gknapsettings

-- Start compilation when a LaTeX file is opened
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufWrite" }, {
	pattern = { "main.tex" },
    callback = function() knap.process_once() end,
})

-- Remaps to useful commands
vim.keymap.set({"n", "v"}, "<leader>x", function()
    knap.close_viewer()
end)
vim.keymap.set({"n", "v"}, "<leader>c", function()
    knap.toggle_autopreviewing()
end)
vim.keymap.set({"n", "v"}, "<leader>y", function()
    knap.forward_jump()
end)
