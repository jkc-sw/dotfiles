
require'my_custom_lsp'
local defaults = require'defaults'
local nvim_lsp = require'nvim_lsp'
local vim = vim

local on_attach_vim = function(client)
    require'completion'.on_attach(client)
    require'diagnostic'.on_attach(client)
end

local construct_statusline = function()
  if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
    local ecnt = vim.lsp.util.buf_diagnostics_count([[Error]]) or 0
    local wcnt = vim.lsp.util.buf_diagnostics_count([[Warning]]) or 0
    local err = (ecnt > 0) and string.format(' %d', ecnt) or ''
    local spacer = (ecnt > 0) and ' ' or ''
    local wan = (wcnt > 0) and string.format(' %d', wcnt) or ''
    local line = string.format('%s%s%s', err, spacer, wan)
    return line
  end
  return ''
end

local setup_lsp = function()

  -- clangd
  -- nvim_lsp.clangd.setup{on_attach=require'completion'.on_attach}
  nvim_lsp.clangd.setup{
    filetypes = { "c", "cpp", "cc", "objc", "objcpp" },
    on_attach=on_attach_vim,
  }

  -- rust
  -- if vim.fn.executable('rls') == 1 then
  --     nvim_lsp.rls.setup{on_attach=on_attach_vim}
  -- end
  nvim_lsp.rust_analyzer.setup{on_attach=on_attach_vim}

  -- lua
  local luals = nvim_lsp.sumneko_lua
  luals.setup{on_attach=on_attach_vim}
  if not luals.install_info().is_installed then
    luals.install()
  end

  -- json
  local jsonls = nvim_lsp.jsonls
  jsonls.setup{on_attach=on_attach_vim}
  if not jsonls.install_info().is_installed then
    jsonls.install()
  end

  -- bash
  local bashls = nvim_lsp.bashls
  bashls.setup{on_attach=on_attach_vim}
  if not bashls.install_info().is_installed then
    bashls.install()
  end

  -- docker
  local dockerls = nvim_lsp.dockerls
  dockerls.setup{on_attach=on_attach_vim}
  if not dockerls.install_info().is_installed then
    dockerls.install()
  end

  -- yaml
  local yamlls = nvim_lsp.yamlls
  yamlls.setup{on_attach=on_attach_vim}
  if not yamlls.install_info().is_installed then
    yamlls.install()
  end

  -- tsserver
  local tsserver = nvim_lsp.tsserver
  tsserver.setup{on_attach=on_attach_vim}
  if not tsserver.install_info().is_installed then
    tsserver.install()
  end

  -- cmake
  nvim_lsp.cmake.setup{
    cmd = {defaults.lsp_condaenv_bin..'cmake-language-server'},
    on_attach = on_attach_vim
  }

  -- python
  if vim.fn.executable('pyls') then
    nvim_lsp.pyls.setup{
      on_attach=on_attach_vim,
      settings={
        pyls={plugins={pycodestyle={maxLineLength=100}}}
      }
    }
  end

  -- my custom section

  -- hdl
  nvim_lsp.hdl_checker.setup{on_attach=on_attach_vim}

  -- pwsh
  -- nvim_lsp.powershell_editor_service.setup{on_attach=on_attach_vim}

end

local start_mylsp = function()
  nvim_lsp.powershell_editor_service.setup{on_attach=on_attach_vim}
end

return {
  setup_lsp = setup_lsp,
  on_attach_vim = on_attach_vim,
  start_mylsp = start_mylsp,
  construct_statusline = construct_statusline
}

-- vim:et ts=2 sw=2
