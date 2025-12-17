local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local special_chars = {
  { char = '—', name = 'Em dash' },
  { char = '–', name = 'En dash' },
  { char = '•', name = 'Bullet' },
  { char = '…', name = 'Ellipsis' },
  { char = '±', name = 'Plus-minus' },
  { char = '§', name = 'Section' },
  { char = '¶', name = 'Paragraph' },
}

local function insert_special_char()
  pickers
    .new({}, {
      prompt_title = 'Special Characters',
      finder = finders.new_table {
        results = special_chars,
        entry_maker = function(entry)
          return {
            value = entry.char,
            display = entry.name .. '  (' .. entry.char .. ')',
            ordinal = entry.name .. entry.char,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(_, map)
        actions.select_default:replace(function(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          vim.api.nvim_put({ selection.value }, 'c', true, true)
        end)
        return true
      end,
    })
    :find()
end

-- Keymap to open it
vim.keymap.set('n', '<leader>sc', insert_special_char, { desc = 'Insert special char' })
