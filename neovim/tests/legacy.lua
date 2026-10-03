vim.opt.rtp:append('/root/.local/share/jerry-dotfiles/neovim/.config/nvim/pack/jerry/start/jerry')
-- Nix supplies the third-party plugins on work machines. Stub only that boundary
-- to verify the preserved Home Manager profile without installing its ecosystem.
local calls = 0
package.preload['jerry.integrations.home_manager'] = function()
  return { setup = function() calls = calls + 1 end }
end
require('jerry').setup({ features = { home_manager = true } })
require('jerry').setup({ features = { home_manager = true } })
assert(calls == 1)
assert(vim.g.jerry_legacy)
assert(vim.o.signcolumn == 'no')
assert(vim.fn.maparg(' b', 'n') ~= '')
assert(package.loaded['jerry.lua-tools'])
assert(vim.fn.exists(':LuaFormat') == 2)
print('Home Manager profile checks passed (third-party boundary stubbed)')
