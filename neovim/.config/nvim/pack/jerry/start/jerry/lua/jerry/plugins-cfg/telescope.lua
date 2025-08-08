require('telescope').setup({
  defaults = {
    preview          = {
      filesize_limit = 1, -- MB
      treesitter = false,
    },
    file_sorter      = require('telescope.sorters').get_fzy_sorter,
    color_devicons   = false,
    file_previewer   = require('telescope.previewers').vim_buffer_cat.new,
    grep_previewer   = require('telescope.previewers').vim_buffer_vimgrep.new,
    qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
    sorting_strategy = 'ascending',
    layout_strategy  = 'vertical',
    layout_config    = {
      prompt_position = 'top',
      horizontal = {
        mirror = true,
      },
      vertical = {
        mirror = true,
      },
    },
    mappings         = {
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
      fuzzy = true,                   -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true,    -- override the file sorter
      case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
    ["ui-select"] = {
      require("telescope.themes").get_dropdown{}
    }
    -- fzy_native = {
    --   override_generic_sorter = false,
    --   override_file_sorter = true,
    -- }
  }
})

-- require('telescope').load_extension('fzy_native')
require('telescope').load_extension('fzf')
-- To get ui-select loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("ui-select")
