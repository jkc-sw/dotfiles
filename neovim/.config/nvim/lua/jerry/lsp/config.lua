
require'jerry.lsp.setup'

local vars = require'jerry.lsp.vars'
local lspconfig = require'lspconfig'
local vim = vim

local on_attach_vim = function(client)
  -- Not used
    -- require'completion'.on_attach(client)
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

local general_lsp = function()

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
  luals.setup{
		cmd = {vars.luals_repos .. 'bin/Linux/lua-language-server', "-E", vars.luals_repos .. "main.lua"};
		settings = {
			Lua = {
				runtime = {
					version = 'LuaJIT', -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
					path = vim.split(package.path, ';'), -- Setup your lua path
				},
				diagnostics = {
					globals = {'vim'}, -- Get the language server to recognize the `vim` global
				},
				workspace = {
					-- Make the server aware of Neovim runtime files
					library = {
						[vim.fn.expand('$VIMRUNTIME/lua')] = true,
						[vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
					},
				},
			},
		},
		on_attach=on_attach_vim
	}

  -- json
  local jsonls = lspconfig.jsonls
  jsonls.setup{on_attach=on_attach_vim}

  -- bash
  local bashls = lspconfig.bashls
  bashls.setup{on_attach=on_attach_vim}

  -- docker
  local dockerls = lspconfig.dockerls
  dockerls.setup{on_attach=on_attach_vim}

  -- yaml
  local yamlls = lspconfig.yamlls
  yamlls.setup{on_attach=on_attach_vim}

  -- tsserver
  local tsserver = lspconfig.tsserver
  tsserver.setup{on_attach=on_attach_vim}

  -- cmake
  lspconfig.cmake.setup{
    cmd = {vars.lsp_condaenv_bin..'cmake-language-server'},
    on_attach = on_attach_vim
  }

  -- python
  if vim.fn.executable('pyls') == 1 then
    lspconfig.pyls.setup{
      on_attach=on_attach_vim,
      settings={
        pyls={plugins={pycodestyle={maxLineLength=150}}}
      }
    }
  end

  lspconfig.pyright.setup{
    on_attach=on_attach_vim
  }


  -- my custom section

  -- hdl
  lspconfig.hdl_checker.setup{on_attach=on_attach_vim}

  -- pwsh
  -- nvim_lsp.powershell_editor_service.setup{on_attach=on_attach_vim}

end

local alternative_lsp = function()
  lspconfig.powershell_editor_service.setup{on_attach=on_attach_vim}
end

return {
  general_lsp = general_lsp,
  on_attach_vim = on_attach_vim,
  alternative_lsp = alternative_lsp,
  construct_statusline = construct_statusline
}

-- vim:et ts=2 sw=2
