
require('jerry.helpers')

S = function(...) R('jerry.term').send(...) end
SV = function(...) R('jerry.term').send_visual(...) end

require('colorbuddy').colorscheme('gruvbuddy')

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
    ensure_installed = "maintained",
    highlight = { enable = true },
    indent = {
        enable = true,
        disable = { 'python' }
    }
}

require('nvim-web-devicons').setup{}

local actions = require('telescope.actions')
require('telescope').setup({
    defaults = {
        file_sorter = require('telescope.sorters').get_fzy_sorter,
        color_devicons = true,
        file_previewer   = require('telescope.previewers').vim_buffer_cat.new,
        grep_previewer   = require('telescope.previewers').vim_buffer_vimgrep.new,
        qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
        prompt_position = 'top',
        sorting_strategy = 'ascending',
        layout_defaults = {
            horizontal = {
                mirror = true,
            },
            vertical = {
                mirror = true,
            },
        },
        mappings = {
            i = {
                ["<C-q>"] = actions.send_to_qflist,
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
