require('nvim_context_vt').setup({
  -- -- Override default virtual text prefix
  -- -- Default: '-->'
  -- prefix = '',

  -- -- Override the internal highlight group name
  -- -- Default: 'ContextVt'
  -- highlight = 'CustomContextVt',

  -- -- Disable virtual text for given filetypes
  -- -- Default: {}
  -- disable_ft = { 'markdown' },

  -- Disable display of virtual text below blocks for indentation based languages like Python
  -- Default: false
  disable_virtual_lines = true, -- TEMP this is making the search jump out of place

  -- -- Same as above but only for spesific filetypes
  -- -- Default: {}
  -- disable_virtual_lines_ft = { 'yaml' },
  --
  -- -- How many lines required after starting position to show virtual text
  -- -- Default: 1 (equals two lines total)
  -- min_rows = 1,
  --
  -- -- Custom virtual text node parser callback
  -- -- Default: nil
  -- custom_parser = function(node, ft, opts)
  --   local ts_utils = require('nvim-treesitter.ts_utils')
  --
  --   -- If you return `nil`, no virtual text will be displayed.
  --   if node:type() == 'function' then
  --     return nil
  --   end
  --
  --   -- This is the standard text
  --   return '--> ' .. ts_utils.get_node_text(node)[1]
  -- end,
  --
  -- -- Custom node validator callback
  -- -- Default: nil
  -- custom_validator = function(node, ft, opts)
  --   -- Internally a node is matched against min_rows and configured targets
  --   local default_validator = require('nvim_context_vt.utils').default_validator
  --   if default_validator(node, ft) then
  --     -- Custom behaviour after using the internal validator
  --     if node:type() == 'function' then
  --       return false
  --     end
  --   end
  --
  --   return true
  -- end,
  --
  -- -- Custom node virtual text resolver callback
  -- -- Default: nil
  -- custom_resolver = function(nodes, ft, opts)
  --   -- By default the last node is used
  --   return nodes[#nodes]
  -- end,
})
