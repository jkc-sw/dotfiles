
require'powershell_editor_service'

local setup_lsp = function()
  local on_attach_vim = function(client)
    require'completion'.on_attach(client)
    require'diagnostic'.on_attach(client)
  end
  -- require'nvim_lsp'.clangd.setup{on_attach=require'completion'.on_attach}
  if vim.fn.executable('clangd-10') == 1 then
    require'nvim_lsp'.clangd.setup{on_attach=on_attach_vim}
  end
  require'nvim_lsp'.powershell_editor_service.setup{on_attach=on_attach_vim}
  -- if vim.fn.executable('rls') == 1 then
  --     require'nvim_lsp'.rls.setup{on_attach=on_attach_vim}
  -- end
  if vim.fn.executable('rust-analyzer') == 1 then
    require'nvim_lsp'.rust_analyzer.setup{on_attach=on_attach_vim}
  end
  local luals = require'nvim_lsp'.sumneko_lua
  luals.setup{on_attach=on_attach_vim}
  if not luals.install_info().is_installed then
    luals.install()
  end
  if vim.fn.executable('pyls') == 1 then
    require'nvim_lsp'.pyls.setup{
      on_attach=on_attach_vim,
      settings={
        pyls={plugins={pycodestyle={maxLineLength=100}}}
      }
    }
  end
end

return {
  setup_lsp = setup_lsp
}

-- vim:et ts=2 sw=2
