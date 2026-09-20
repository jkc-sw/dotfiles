if not vim.g.jerry_enabled then
  return
end

require('jerry.markdown').setup_buffer()
require('jerry.markdown_links').setup_buffer()

-- vim:et ts=2 sts=2 sw=2
