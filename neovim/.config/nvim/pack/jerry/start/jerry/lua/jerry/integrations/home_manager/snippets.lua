-- Adapted from LazyVim; Apache-2.0 (see LAZYVIM-LICENSE).
-- Adapted from LazyVim 16.0.1's native snippet helper.
local M = {}

local function replace(snippet, fn)
  return snippet:gsub('%$%b{}', function(placeholder)
    local n, text = placeholder:match '^%${(%d+):(.+)}$'
    return n and fn(tonumber(n), text) or placeholder
  end)
end

local function preview(snippet)
  local ok, parsed = pcall(vim.lsp._snippet_grammar.parse, snippet)
  if ok then
    return tostring(parsed)
  end
  return (replace(snippet, function(_, text)
    return preview(text)
  end):gsub('%$0', ''))
end

function M.fix(snippet)
  local texts = {}
  return replace(snippet, function(n, text)
    texts[n] = texts[n] or preview(text)
    return '${' .. n .. ':' .. texts[n] .. '}'
  end)
end

function M.expand(snippet)
  -- Preserve the outer session when accepting a completion inside a placeholder.
  local session = vim.snippet.active() and vim.snippet._session or nil
  local ok, err = pcall(vim.snippet.expand, snippet)
  if not ok then
    ok = pcall(vim.snippet.expand, M.fix(snippet))
    vim.notify(
      ok and 'Failed to parse snippet, but fixed it automatically.' or ('Failed to parse snippet.\n' .. err),
      ok and vim.log.levels.WARN or vim.log.levels.ERROR,
      { title = 'vim.snippet' }
    )
  end
  if session then
    vim.snippet._session = session
  end
end

return M
