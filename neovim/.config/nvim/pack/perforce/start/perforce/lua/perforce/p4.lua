local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values
local utils = require('telescope.utils')

local p4 = {}

p4.opened = function(opts)

  opts.entry_maker = opts.entry_maker or make_entry.gen_from_file(opts)

  local fd = finders.new_oneshot_job(
    vim.tbl_flatten({'p4opened.sh'}),
    opts
  )

  pickers.new(opts, {
    prompt_title = 'P4 Opened',
    finder = fd,
    previewer = conf.file_previewer(opts),
    sorter = conf.file_sorter(opts),
  }):find()
end

return p4

-- vim:et ts=2 sw=2
