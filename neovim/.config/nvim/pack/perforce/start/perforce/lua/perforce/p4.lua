local p4 = {}

--- Pick from the files `p4opened.sh` lists, one path per line.
p4.opened = function(opts)
  require('snacks').picker.pick(vim.tbl_extend('force', {
    source = 'p4_opened',
    title = 'P4 Opened',
    format = 'file',
    preview = 'file',
    finder = function(finder_opts, ctx)
      local cwd = vim.fs.normalize(finder_opts.cwd or vim.uv.cwd())
      return require('snacks.picker.source.proc').proc(
        ctx:opts {
          cmd = 'p4opened.sh',
          transform = function(item)
            item.cwd = cwd
            item.file = item.text
          end,
        },
        ctx
      )
    end,
  }, opts or {}))
end

return p4

-- vim:et ts=2 sw=2
