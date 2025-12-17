-- lua/myutils/goto_file.lua
local M = {}

function M.goto_or_create_file(path)
  local base = vim.fn.expand '%:p:h'
  local file = vim.fn.fnamemodify(base .. '/' .. path, ':p')

  if vim.fn.filereadable(file) == 1 or vim.fn.isdirectory(file) == 1 then
    vim.cmd('edit ' .. file)
    return
  end

  require('snacks.input').input({
    prompt = "File doesn't exist: Create it (including dirs)? [y/N]: ",
  }, function(input)
    if input and input:lower() == 'y' then
      vim.fn.mkdir(vim.fn.fnamemodify(file, ':h'), 'p')
      vim.cmd('edit ' .. file)
    end
  end)
end

return M
