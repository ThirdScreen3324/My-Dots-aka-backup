-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
      renderers = {
        -- File renderer (uses built-in symlink_target)
        file = {
          { 'indent' },
          { 'icon' },
          {
            'container',
            content = {
              { 'name', zindex = 10 },
              {
                'symlink_target',
                enabled = true,
                highlight = 'NeoTreeSymbolicLinkTarget',
                text_format = ' → %s',
                zindex = 10,
              },
              { 'clipboard', zindex = 10 },
            },
          },
        },
        -- Folder renderer with custom symlink component
        directory = {
          { 'indent' },
          { 'icon' },
          {
            'container',
            content = {
              { 'name', zindex = 10 },
              {
                'symlink_target',
                enabled = true,
                highlight = 'NeoTreeSymbolicLinkTarget',
                text_format = ' → %s',
                zindex = 10,
              },
              { 'clipboard', zindex = 10 },
            },
          },
        },
      },
    },
  },
  config = function(_, opts)
    require('neo-tree').setup(opts)

    -- Custom highlight for symlink targets using Tokyonight colors
    local colors = require('tokyonight.colors').setup()
    vim.api.nvim_set_hl(0, 'NeoTreeSymbolicLinkTarget', {
      fg = colors.yellow,
      italic = true,
    })
  end,
}
