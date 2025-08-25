-- For compiling markdown files to PDF and opening them in Zathura.

local pandoc_options = "-s -V papersize:a4 -V geometry:margin=1.5in"

-- Required commands.
vim.api.nvim_create_user_command('CompileMarkdown',
  function(opts)
    if vim.bo.filetype == "markdown" then
      print("Compiling to PDF...")
      local function compile_finished(chan_id, data, name)
        print("Compiled to PDF.")
      end
      local in_path = vim.fn.expand("%:p")
      local out_path = vim.fn.expand("%:p:r") .. ".pdf"
      vim.fn.jobstart("pandoc " .. pandoc_options .. " -o " .. out_path .. " " .. in_path, { on_exit = compile_finished })
    else
      print("Not a markdown file!")
    end
  end,
  {}
)

vim.api.nvim_create_user_command('OpenZathura',
  function(opts)
    local to_open = vim.fn.expand("%:p:r") .. ".pdf"
    if vim.fn.filereadable(to_open) == 1 then
      print("Opened Zathura.")
      vim.fn.jobstart("zathura " .. to_open)
    else
      print("PDF version not found!")
    end
  end,
  {}
)

-- Useful remaps.
vim.keymap.set("n", "<leader>p", "<cmd>CompileMarkdown<cr>")
vim.keymap.set("n", "<leader>o", "<cmd>OpenZathura<cr>")

