
local vim = vim

local M = {}

M.get_term_id_list = function()
  return vim.tbl_map(function(buf)
      return buf.variables.terminal_job_id
    end, vim.tbl_filter(function(buf)
      if vim.tbl_contains(vim.tbl_keys(buf), 'variables') then
        if vim.tbl_contains(vim.tbl_keys(buf.variables), 'terminal_job_id') then
          return true
        end
      end
      return false
  end, vim.fn.getbufinfo()))
end

M.get_term_id = function()
  local terms = M.get_term_id_list()
  if #terms < 1 then
    local current_id = vim.fn.bufnr()
    vim.cmd [[ terminal ]]
    vim.api.nvim_set_current_buf(current_id)
    return M.get_term_id_list()[1]
  else
    return terms[1]
  end
end

return M

-- vim:et sw=2 ts=2 sts=2
