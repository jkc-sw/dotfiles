
require('jerry.helpers')

S = function(...) R('jerry.term').send(...) end
SV = function() R('jerry.term').send_visual() end
SL = function() R('jerry.term').send(vim.fn.getline('.')) end

RT = function(...) R('jerry.asyncjob').run_to_tab(...) end
RS = function(...) R('jerry.asyncjob').run_to_split(...) end
RV = function(...) R('jerry.asyncjob').run_to_vsplit(...) end

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

require('compe').setup {
  enabled = true,
  autocomplete = true,
  debug = false,
  min_length = 1,
  preselect = 'enable',
  throttle_time = 80,
  source_timeout = 200,
  incomplete_delay = 400,
  max_abbr_width = 100,
  max_kind_width = 100,
  max_menu_width = 100,
  documentation = true,

  source = {
    path = true,
    buffer = true,
    calc = true,
    vsnip = true,
    nvim_lsp = true,
    nvim_lua = true,
    spell = true,
    tags = true,
    snippets_nvim = true,
    treesitter = true,
  },
}

require('nvim-treesitter.configs').setup{
    highlight = {
      enable = true,
      -- disable = { 'python' }
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
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        }
    }
})

require('telescope').load_extension('fzy_native')

require('lspsaga').init_lsp_saga()

-- vim:et sw=2 ts=2 sts=2
