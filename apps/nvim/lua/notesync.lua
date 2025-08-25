
-- Displays a terminal commands progress to a buffer on the bottom.
function display_shell_progress(command, title, message_start, message_end, callback)

  -- Get the current focused window before creating a new one
  local current_win = vim.api.nvim_get_current_win()

  -- Create a new buffer for displaying the output
  -- False means it's not listed, true means it’s scratch
  local bufnr = vim.api.nvim_create_buf(false, true) 

  local function remove_empty_lines()
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    for i = line_count, 2, -1 do
      local line = vim.api.nvim_buf_get_lines(bufnr, i-1, i, false)[1]
      if line == "" then
        -- Remove the empty line
        vim.api.nvim_buf_set_lines(bufnr, i-1, i, false, {})
      end
    end
  end
  
  -- Set the buffer in a split at the bottom of the screen
  vim.api.nvim_command("botright new")
  vim.api.nvim_win_set_buf(0, bufnr)
  vim.api.nvim_win_set_height(0, 3)
  local winid = vim.api.nvim_get_current_win()

  vim.api.nvim_buf_set_option(bufnr, 'number', false)
  vim.api.nvim_buf_set_option(bufnr, 'relativenumber', false)
  vim.api.nvim_buf_set_option(bufnr, 'spell', false)
  vim.api.nvim_buf_set_option(bufnr, 'wrap', false)
  vim.api.nvim_win_set_option(winid, 'colorcolumn', '')
  vim.api.nvim_buf_set_name(bufnr, title)  -- Rename the buffer to "file upload"

  vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {message_start})

  -- Start the shell job
  vim.fn.jobstart(command, {
    out_name = "joboutput", pty = 1,
    on_stdout = function(_, data, _)
      -- Update the buffer with the output line by line
      if data then
        for _, line in ipairs(data) do
          line = line:gsub("\r", "")
          line = line:gsub("\n", "")
          line = line:gsub("as%s%-%-dry%-run.*", "")
          line = line:gsub("\27%[[%d;]*[mK]", "")
          vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {line})
        end
        remove_empty_lines()
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        vim.api.nvim_win_set_height(winid, math.min(line_count + 1, 30))
        vim.api.nvim_win_set_cursor(winid, {line_count, 0})
      end
    end,
    on_exit = function()
      vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {message_end})
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      vim.api.nvim_win_set_height(winid, math.min(line_count + 1, 30))
      vim.api.nvim_win_set_cursor(winid, {line_count, 0})
      vim.defer_fn(function()
        callback(winid, bufnr)
      end, 50)
    end
  })

  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', ':bd!<CR>', { noremap = true, silent = true })

  -- Move the focus back to the starting window.
  -- vim.api.nvim_set_current_win(current_win)
end


-- Complete note operation, with and initial dry run for confirmation.
function noteOperation(name, command)
  print("Dry run...") 
  display_shell_progress(
  command .. " --dry-run",
  "Dry " .. name,
  "Starting Dry " .. name .. "...",
  "Dry " .. name .. " finished!",
  function(winid, bufnr)
    vim.ui.input({ prompt = "Apply changes? [y/N]: " }, function(input)

      -- Close the buffer
      vim.api.nvim_win_close(winid, true)
      vim.api.nvim_buf_delete(bufnr, {force = true})

      -- If the user answer is yes.
      if input == "y" or input == "Y" then
        print("Live run...")
        display_shell_progress(
        command,
        name,
        "Starting " .. name .. "...",
        name .. " finished!",
        function(winid, bufnr) 
          print(name .. " finished, changes applied!")
        end
        )
      else
        print(name .. " cancelled, no changes made!")
      end

    end)
  end
  )
end


-- Simple write and read commands.
vim.api.nvim_create_user_command('NoteWrite',
  function(opts)
    noteOperation(
      "Note Write",
      "rclone sync ~/Notes Notes:/ -v --exclude-from ~/Notes/.rsyncignore"
    )
  end,
  { nargs = 0 }
)

vim.api.nvim_create_user_command('NoteRead',
  function(opts)
    noteOperation(
      "Note Read",
      "rclone sync Notes:/ ~/Notes -v --exclude-from ~/Notes/.rsyncignore"
    )
  end,
  { nargs = 0 }
)

-- Bisync command: "rclone bisync ~/Notes Notes:/ -v --exclude-from ~/Notes/.rsyncignore",
-- Resync command: "rclone bisync ~/Notes Notes:/ -v --exclude-from ~/Notes/.rsyncignore --resync --resync-mode newer",

