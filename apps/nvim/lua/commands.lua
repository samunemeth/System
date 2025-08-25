--- Commands ---

-- Typo fixes
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Q", "q", {})

-- For easy management of systemd processes
vim.api.nvim_create_user_command('Systemd',
  function(opts)
    vim.fn.jobstart("sudo systemctl " .. opts.fargs[1])
  end,
  { nargs = 1 }
)

