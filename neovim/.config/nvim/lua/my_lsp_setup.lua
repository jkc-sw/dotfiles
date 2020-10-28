
require'my_custom_lsp'
local defaults = require'defaults'

local on_attach_vim = function(client)
    require'completion'.on_attach(client)
    require'diagnostic'.on_attach(client)
end

local setup_lsp = function()

  -- clangd
  -- require'nvim_lsp'.clangd.setup{on_attach=require'completion'.on_attach}
  require'nvim_lsp'.clangd.setup{
    filetypes = { "c", "cpp", "cc", "objc", "objcpp" },
    on_attach=on_attach_vim
  }

  -- rust
  -- if vim.fn.executable('rls') == 1 then
  --     require'nvim_lsp'.rls.setup{on_attach=on_attach_vim}
  -- end
  require'nvim_lsp'.rust_analyzer.setup{on_attach=on_attach_vim}

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

  -- cmake
  require'nvim_lsp'.cmake.setup{
    cmd = {defaults.lsp_condaenv_bin..'cmake-language-server'},
    on_attach = on_attach_vim
  }

  -- python
  require'nvim_lsp'.pyls.setup{
    on_attach=on_attach_vim,
    settings={
      pyls={plugins={pycodestyle={maxLineLength=100}}}
    }
  }

  -- my custom section

  -- hdl
  require'nvim_lsp'.hdl_checker.setup{on_attach=on_attach_vim}

  -- pwsh
  -- require'nvim_lsp'.powershell_editor_service.setup{on_attach=on_attach_vim}

end

local start_mylsp = function()
  require'nvim_lsp'.powershell_editor_service.setup{on_attach=on_attach_vim}
end

return {
  setup_lsp = setup_lsp,
  on_attach_vim = on_attach_vim,
  start_mylsp = start_mylsp
}

-- vim:et ts=2 sw=2
