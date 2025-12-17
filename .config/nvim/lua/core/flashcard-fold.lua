function _G.FlashcardFolds()
  local line = vim.fn.getline(vim.v.lnum)
  if line:match '^```flashcards' then
    return '>1' -- start fold
  elseif line:match '^```' then
    return '<1' -- end fold
  else
    return '='
  end
end

-- Apply folding only to markdown buffers
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.opt_local.foldmethod = 'expr'
    vim.opt_local.foldexpr = 'v:lua.FlashcardFolds()'
    vim.opt_local.foldlevel = 0 -- folds closed by default
  end,
})
