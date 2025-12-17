vim.keymap.set('n', 'n', 'nzzzv', { noremap = true, silent = true })
vim.keymap.set('n', 'N', 'Nzzzv', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Close current buffer' })

-- open file on gf
vim.keymap.set('n', 'gf', function()
  local raw = vim.fn.expand '<cfile>'
  require('custom.plugins.goto_file').goto_or_create_file(raw)
end, { noremap = true, silent = true })

-- open file link on return inside markdown
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.keymap.set('n', '<CR>', function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1

      local path = nil

      -- Check for markdown links [text](path)
      local pattern_md = '%[.-%]%((.-)%)'
      local i = 1
      while true do
        local s, e, match = line:find(pattern_md, i)
        if not s then
          break
        end
        if col >= s and col <= e then
          path = match
          break
        end
        i = e + 1
      end

      -- If not found, check for wiki-style links [[path]]
      if not path then
        local pattern_wiki = '%[%[(.-)%]%]'
        local i = 1
        while true do
          local s, e, match = line:find(pattern_wiki, i)
          if not s then
            break
          end
          if col >= s and col <= e then
            path = match
            break
          end
          i = e + 1
        end
      end

      if path then
        require('custom.plugins.goto_file').goto_or_create_file(path)
        return
      end

      -- Fallback to normal <CR>
      return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
    end, { buffer = true, silent = true })
  end,
})

-- smart tab stop
vim.keymap.set('i', '<Tab>', function()
  local col = vim.fn.col '.' - 1
  local line = vim.fn.getline '.'
  local before = string.sub(line, 1, col)

  -- Get leading whitespace from beginning of line
  local leading = line:match '^(%s*)' or ''
  local in_leading_indent = (#before == #leading)

  if in_leading_indent then
    -- Case: We're in leading indentation

    if leading:find '\t' then
      -- Tabs present → use tab
      return '\t'
    elseif leading:find ' ' then
      -- Only spaces present → use spaces to next tabstop
      local ts = vim.o.tabstop
      local spaces = ts - (col % ts)
      return string.rep(' ', spaces)
    else
      -- Line is empty → use tab
      return '\t'
    end
  else
    -- After text → always use spaces to next tabstop
    local ts = vim.o.tabstop
    local spaces = ts - (col % ts)
    return string.rep(' ', spaces)
  end
end, { expr = true, noremap = true })

vim.keymap.set('i', '<S-Tab>', function()
  return '\b' -- backspace
end, { expr = true, noremap = true })

-- Tab switching like <leader>1 to go to tab 1
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, function()
    local bufs = vim.fn.getbufinfo { buflisted = 1 }
    table.sort(bufs, function(a, b)
      return a.bufnr < b.bufnr
    end) -- mimic bufferline order
    if bufs[i] then
      vim.api.nvim_set_current_buf(bufs[i].bufnr)
    end
  end, { noremap = true, silent = true })
end

vim.keymap.set('n', '<leader>C', function()
  vim.cmd 'write' -- Save the file first
  local filename = vim.fn.expand '%'
  local cmd = { 'compile', filename }

  local main_win = vim.api.nvim_get_current_win() -- Save the current "main" window

  -- Open a split for terminal
  vim.cmd 'botright split | resize 15'
  local term_win = vim.api.nvim_get_current_win()
  local term_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(term_win, term_buf)

  vim.fn.termopen(cmd, {
    on_exit = function(_, code, _)
      vim.schedule(function()
        vim.api.nvim_buf_set_option(term_buf, 'modifiable', true)

        if code == 0 then
          vim.api.nvim_buf_set_lines(term_buf, -1, -1, false, {
            '',
            '✅ Compile finished successfully.',
          })
          vim.api.nvim_buf_set_option(term_buf, 'modifiable', false)

          -- Close terminal window after delay
          vim.defer_fn(function()
            if vim.api.nvim_win_is_valid(term_win) then
              vim.api.nvim_win_close(term_win, true)
            end

            -- Restore focus to main buffer
            if vim.api.nvim_win_is_valid(main_win) then
              vim.api.nvim_set_current_win(main_win)
            end
          end, 1000)
        else
          vim.api.nvim_buf_set_lines(term_buf, -1, -1, false, {
            '',
            '❌ Compile failed. See output above.',
          })
          vim.api.nvim_buf_set_option(term_buf, 'modifiable', false)

          -- Restore focus immediately on failure
          if vim.api.nvim_win_is_valid(main_win) then
            vim.api.nvim_set_current_win(main_win)
          end
        end
      end)
    end,
  })

  vim.cmd 'startinsert'
end, { noremap = true, silent = true })

local function get_frontmatter_exec()
  local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
  local in_frontmatter = false
  local exec_cmd = nil

  for _, line in ipairs(lines) do
    if line:match '^%-%-%-$' then
      if in_frontmatter then
        break
      end
      in_frontmatter = true
    elseif in_frontmatter then
      local key, val = line:match '^([%w_]+):%s*(.+)$'
      if key == 'exec' then
        exec_cmd = val
        break
      end
    end
  end

  return exec_cmd
end

vim.api.nvim_set_keymap('n', '<leader>p', '', {
  noremap = true,
  callback = function()
    local cmd_template = get_frontmatter_exec()
    if not cmd_template then
      print 'No exec command in frontmatter'
      return
    end

    local function shell_escape(str)
      return "'" .. tostring(str):gsub("'", "'\\''") .. "'"
    end

    local filepath = vim.fn.expand '%:p'
    local safe_filepath = shell_escape(filepath)
    local cmd = cmd_template:gsub('%%f', safe_filepath)

    -- Run asynchronously via jobstart or terminal
    require('snacks.input').input({
      prompt = 'Run exec command? ' .. cmd .. ' (y/N): ',
    }, function(input)
      if input and input:lower() == 'y' then
        vim.fn.jobstart(cmd, { detach = true })
        print('Command executed: ' .. cmd)
      else
        print 'Command canceled'
      end
    end)
  end,
  desc = 'Run frontmatter exec command',
})
