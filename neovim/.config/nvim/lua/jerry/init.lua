
require('jerry.helpers')

S = function(...) require('jerry.term').send(...) end
SV = function() require('jerry.term').send_visual() end
SL = function() require('jerry.term').send(vim.fn.getline('.')) end

RT = function(...) require('jerry.asyncjob').run_to_tab(...) end
RS = function(...) require('jerry.asyncjob').run_to_split(...) end
RV = function(...) require('jerry.asyncjob').run_to_vsplit(...) end

require('jerry.markdown').setup()

require('lualine').setup {
  options = {
    theme = 'jellybeans'
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {require('jerry.asyncjob').job_report, 'branch', {'filename', path = 1}},
    lualine_c = {'jerry#common#PasteModeReport'},
    lualine_x = {'fileformat', 'encoding', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location', {'diagnostics', sources = {'nvim_diagnostic'}, sections = {'error', 'warn'}}},
  },
  inactive_sections = {
    lualine_a = {'jerry#common#CorrentFileShortener'},
    lualine_b = {'location'},
    lualine_c = {'jerry#common#PasteModeReport'},
    lualine_x = {'progress'},
    lualine_y = {},
    lualine_z = {},
  }
}

require('jerry.lsp.config').general_lsp()

require('lspkind').init{}

local cmp = require('cmp')
cmp.setup{
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete()
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    -- { name = 'path' },
  }
}

local neogit = require('neogit')
neogit.setup{}

require('nvim-treesitter.configs').setup{
  sync_install = false,
  auto_install = false,
  context_commentstring = {
    enable = false,
  },
  highlight = {
    enable = true,
    disable = { 'cpp' }
  },
  indent = {
    enable = false,
    disable = { 'python' }
  }
}

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
  disable_virtual_lines = true,  -- TEMP this is making the search jump out of place

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

local actions = require('telescope.actions')

require('telescope').setup({
  defaults = {
    preview = {
      filesize_limit = 1,  -- MB
      treesitter = false,
    },
    file_sorter = require('telescope.sorters').get_fzy_sorter,
    color_devicons = false,
    file_previewer   = require('telescope.previewers').vim_buffer_cat.new,
    grep_previewer   = require('telescope.previewers').vim_buffer_vimgrep.new,
    qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
    sorting_strategy = 'ascending',
    layout_strategy = 'vertical',
    layout_config = {
      prompt_position = 'top',
      horizontal = {
        mirror = true,
      },
      vertical = {
        mirror = true,
      },
    },
    mappings = {
      -- i = {
      --   ["<C-h>"] = function(prompt_nr)
      --     actions.select_vertical(prompt_nr)
      --     vim.cmd [[ FSNoToggle ]]
      --   end,
      -- },
    }
  },
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
    -- fzy_native = {
    --   override_generic_sorter = false,
    --   override_file_sorter = true,
    -- }
  }
})

-- require('telescope').load_extension('fzy_native')
require('telescope').load_extension('fzf')

-- -- [UNMAINTAINED] Lspsaga hasn't been maintained for a long time.
-- require('lspsaga').init_lsp_saga{
--   code_action_prompt = {
--     enable = false
--   }
-- }

require'colorizer'.setup()

-- Add custom filetype
vim.filetype.add({
  extensions = {
    inc = 'bitbake',
    keymap = 'keymap',
  }
})

-- vim:et sw=2 ts=2 sts=2
