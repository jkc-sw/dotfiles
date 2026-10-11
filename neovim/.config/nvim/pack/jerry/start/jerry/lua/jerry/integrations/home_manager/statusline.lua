-- Adapted from LazyVim; Apache-2.0 (see LAZYVIM-LICENSE).
-- LazyVim's project and filename presentation without a lazy.nvim dependency.
local M = {}
local root = require('jerry.integrations.home_manager.keymaps').root

local function highlight(component, text, group)
  text = text:gsub('%%', '%%%%')
  component.hl_cache = component.hl_cache or {}
  if not component.hl_cache[group] then
    local utils = require 'lualine.utils.utils'
    component.hl_cache[group] = component:create_hl({
      fg = utils.extract_highlight_colors(group, 'fg'),
      gui = utils.extract_highlight_colors(group, 'bold') and 'bold' or nil,
    }, 'Jerry_' .. group)
  end
  return component:format_hl(component.hl_cache[group]) .. text .. component:get_default_hl()
end

function M.pretty_path(component)
  local path = vim.fn.expand '%:p'
  if path == '' then
    return ''
  end
  local cwd, project = vim.fn.getcwd(), root()
  for _, base in ipairs { cwd, project } do
    if path:sub(1, #base + 1) == base .. '/' then
      path = path:sub(#base + 2)
      break
    end
  end
  local parts = vim.split(path, '/')
  if #parts > 3 then
    parts = { parts[1], '…', unpack(parts, #parts - 1) }
  end
  parts[#parts] = highlight(component, parts[#parts], vim.bo.modified and 'MatchParen' or 'Bold')
  return table.concat(parts, '/') .. (vim.bo.readonly and highlight(component, ' 󰌾 ', 'MatchParen') or '')
end

function M.root_dir()
  return {
    function()
      return '󱉭  ' .. vim.fs.basename(root())
    end,
    cond = function()
      return root() ~= vim.fn.getcwd()
    end,
    color = function()
      return { fg = require('snacks').util.color 'Special' }
    end,
  }
end

return M
