return {
  'rmagatti/auto-session',
  config = function()
    require('auto-session').setup {
      log_level = 'info',
      auto_session_enable_last_session = false,
      auto_session_enabled = true,
      auto_save_enabled = true,
      auto_restore_enabled = true,
      auto_session_suppress_dirs = { '~/', '~/Downloads', '/' },
    }

    -- Close neo-tree before saving session to prevent layout issues
    vim.api.nvim_create_autocmd('User', {
      pattern = 'AutoSessionSavePre',
      callback = function()
        pcall(function()
          require('neo-tree.command').execute { action = 'close' }
        end)
      end,
    })
  end,
}
