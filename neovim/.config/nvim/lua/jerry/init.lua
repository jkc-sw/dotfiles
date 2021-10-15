
require('jerry.helpers')

S = function(...) require('jerry.term').send(...) end
SV = function() require('jerry.term').send_visual() end
SL = function() require('jerry.term').send(vim.fn.getline('.')) end

RT = function(...) require('jerry.asyncjob').run_to_tab(...) end
RS = function(...) require('jerry.asyncjob').run_to_split(...) end
RV = function(...) require('jerry.asyncjob').run_to_vsplit(...) end

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
    lualine_z = {'location', {'diagnostics', sources = {'nvim_lsp'}, sections = {'error', 'warn'}}},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'jerry#common#PasteModeReport'},
    lualine_x = {'progress'},
    lualine_y = {'location'},
    lualine_z = {'jerry#common#CorrentFileShortener'},
  }
}

require('jerry.lsp.config').general_lsp()

require('lspkind').init{}

local cmp = require('cmp')
cmp.setup{
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  }
}

require('nvim-treesitter.configs').setup{
  highlight = {
    enable = true,
    -- disable = { 'cpp' }
  },
  indent = {
    enable = true,
    disable = { 'python' }
  }
}

local actions = require('telescope.actions')
require('telescope').setup({
  defaults = {
    file_sorter = require('telescope.sorters').get_fzy_sorter,
    color_devicons = false,
    file_previewer   = require('telescope.previewers').vim_buffer_cat.new,
    grep_previewer   = require('telescope.previewers').vim_buffer_vimgrep.new,
    qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
    sorting_strategy = 'ascending',
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
      i = {
        ["<C-h>"] = function(prompt_nr)
          actions.select_vertical(prompt_nr)
          vim.cmd [[ FSNoToggle ]]
        end,
      },
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

require('lspsaga').init_lsp_saga{
  code_action_prompt = {
    enable = false
  }
}

-- vim:et sw=2 ts=2 sts=2
