local M = {}

--- @brief Send the content to vim.g.clip_supplier, or to the `+` register
--- when no supplier is configured
--- @param content string
M.send_to_clipboard = function(content)
  if not content then
    return
  end
  local supplier = vim.g.clip_supplier
  if type(supplier) ~= 'table' or #supplier < 1 then
    vim.fn.setreg('+', content)
  else
    vim.system({ supplier[1] }, { stdin = content, text = true }):wait()
  end
  vim.fn.setreg('"', content)
end

function M.setup()
  if type(vim.g.clip_supplier) ~= 'table' or vim.fn.executable(vim.g.clip_supplier[1]) ~= 1 then
    return
  end
  vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('jerry_clipboard', { clear = true }),
    callback = function()
      if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
        vim.system(vim.g.clip_supplier, { stdin = vim.fn.getreg '"', text = true })
      end
    end,
  })
end

return M

-- vim:et ts=2 sts=2 sw=2
