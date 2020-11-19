
require'my_custom_lsp'
local defaults = require'defaults'
local lspconfig = require'lspconfig'
local vim = vim

local on_attach_vim = function(client)
    require'completion'.on_attach(client)
end

local construct_statusline = function()
  if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
    local ecnt = vim.lsp.diagnostic.get_count(vim.fn.bufnr('%'), [[Error]]) or 0
    local wcnt = vim.lsp.diagnostic.get_count(vim.fn.bufnr('%'), [[Warning]]) or 0
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
  lspconfig.clangd.setup{
    filetypes = { "c", "cpp", "cc", "objc", "objcpp" },
    on_attach=on_attach_vim,
  }

  -- rust
  -- if vim.fn.executable('rls') == 1 then
  --     nvim_lsp.rls.setup{on_attach=on_attach_vim}
  -- end
  lspconfig.rust_analyzer.setup{on_attach=on_attach_vim}

  -- lua
  local luals = lspconfig.sumneko_lua
  luals.setup{on_attach=on_attach_vim}
  if not luals.install_info().is_installed then
    luals.install()
  end

  -- json
  local jsonls = lspconfig.jsonls
  jsonls.setup{on_attach=on_attach_vim}
  if not jsonls.install_info().is_installed then
    jsonls.install()
  end

  -- bash
  local bashls = lspconfig.bashls
  bashls.setup{on_attach=on_attach_vim}
  if not bashls.install_info().is_installed then
    bashls.install()
  end

  -- docker
  local dockerls = lspconfig.dockerls
  dockerls.setup{on_attach=on_attach_vim}
  if not dockerls.install_info().is_installed then
    dockerls.install()
  end

  -- yaml
  local yamlls = lspconfig.yamlls
  yamlls.setup{on_attach=on_attach_vim}
  if not yamlls.install_info().is_installed then
    yamlls.install()
  end

  -- tsserver
  local tsserver = lspconfig.tsserver
  tsserver.setup{on_attach=on_attach_vim}
  if not tsserver.install_info().is_installed then
    tsserver.install()
  end

  -- cmake
  lspconfig.cmake.setup{
    cmd = {defaults.lsp_condaenv_bin..'cmake-language-server'},
    on_attach = on_attach_vim
  }

  -- python
  if vim.fn.executable('pyls') then
    lspconfig.pyls.setup{
      on_attach=on_attach_vim,
      settings={
        pyls={plugins={pycodestyle={maxLineLength=100}}}
      }
    }
  end

  -- my custom section

  -- hdl
  lspconfig.hdl_checker.setup{on_attach=on_attach_vim}

  -- pwsh
  -- nvim_lsp.powershell_editor_service.setup{on_attach=on_attach_vim}

end

local start_mylsp = function()
  lspconfig.powershell_editor_service.setup{on_attach=on_attach_vim}
end

return {
  setup_lsp = setup_lsp,
  on_attach_vim = on_attach_vim,
  start_mylsp = start_mylsp,
  construct_statusline = construct_statusline
}

-- vim:et ts=2 sw=2
