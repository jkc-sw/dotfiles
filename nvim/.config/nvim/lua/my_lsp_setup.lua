
require'powershell_editor_service'

local setup_lsp = function()

  -- Helper functino to attach completion and diagnosis
  local on_attach_vim = function(client)
    require'completion'.on_attach(client)
    require'diagnostic'.on_attach(client)
  end

  -- clangd
  -- require'nvim_lsp'.clangd.setup{on_attach=require'completion'.on_attach}
  if vim.fn.executable('clangd-10') == 1 then
    require'nvim_lsp'.clangd.setup{on_attach=on_attach_vim}
  end
  require'nvim_lsp'.powershell_editor_service.setup{on_attach=on_attach_vim}

  -- rust
  -- if vim.fn.executable('rls') == 1 then
  --     require'nvim_lsp'.rls.setup{on_attach=on_attach_vim}
  -- end
  if vim.fn.executable('rust-analyzer') == 1 then
    require'nvim_lsp'.rust_analyzer.setup{on_attach=on_attach_vim}
  end

  -- lua
  local luals = require'nvim_lsp'.sumneko_lua
  luals.setup{on_attach=on_attach_vim}
  if not luals.install_info().is_installed then
    luals.install()
  end

  -- json
  local jsonls = require'nvim_lsp'.jsonls
  jsonls.setup{on_attach=on_attach_vim}
  if not jsonls.install_info().is_installed then
    jsonls.install()
  end

  -- bash
  local bashls = require'nvim_lsp'.bashls
  bashls.setup{on_attach=on_attach_vim}
  if not bashls.install_info().is_installed then
    bashls.install()
  end

  -- docker
  local dockerls = require'nvim_lsp'.dockerls
  dockerls.setup{on_attach=on_attach_vim}
  if not dockerls.install_info().is_installed then
    dockerls.install()
  end

  -- yaml
  local yamlls = require'nvim_lsp'.yamlls
  yamlls.setup{on_attach=on_attach_vim}
  if not yamlls.install_info().is_installed then
    yamlls.install()
  end

  -- tsserver
  local tsserver = require'nvim_lsp'.tsserver
  tsserver.setup{on_attach=on_attach_vim}
  if not tsserver.install_info().is_installed then
    tsserver.install()
  end

  -- python
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