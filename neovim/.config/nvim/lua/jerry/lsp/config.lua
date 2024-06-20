
require'jerry.lsp.setup'

local vars = require'jerry.lsp.vars'
local lspconfig = require'lspconfig'
local util = lspconfig.util
local vim = vim

-- local updated_capabilities = vim.lsp.protocol.make_client_capabilities()
-- updated_capabilities = require("cmp_nvim_lsp").update_capabilities(updated_capabilities)
updated_capabilities = require("cmp_nvim_lsp").default_capabilities()

local on_attach_vim = function(client)
  -- require'lsp_signature'.on_attach()  -- This plugin has some ghost buffer remain
end

local function setup_each_lsp(target, opt)
  if not opt then
    return
  end

  if type(opt) ~= 'table' then
    opt = {}
  end

  opt = vim.tbl_deep_extend("force", {
    on_attach = on_attach_vim,
    capabilities = updated_capabilities,
  }, opt)

  lspconfig[target].setup(opt)
end

local general_lsp = function()

  -- clangd
  setup_each_lsp('clangd', {
    filetypes = { "c", "cpp", "cc", "objc", "objcpp" },
  })

  -- -- rust
  -- if vim.fn.executable('rls') == 1 then
  --     setup_each_lsp('rls', true)
  -- end
  setup_each_lsp('rust_analyzer', true)

  -- lua
  setup_each_lsp('lua_ls', {
		cmd = {vars.luals_repos .. 'bin/lua-language-server'};
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
	})

  -- json
  setup_each_lsp('jsonls', true)

  -- bash
  setup_each_lsp('bashls', true)

  -- nix
  -- setup_each_lsp('nil', true)
  setup_each_lsp('nixd', true)

  -- docker
  setup_each_lsp('dockerls', true)

  -- texlab
  setup_each_lsp('texlab', true)

  -- yaml
  setup_each_lsp('yamlls', true)

  -- tsserver
  setup_each_lsp('tsserver', true)

  -- -- haskell -- Cannot get it to work, not sure how to handle the import/setup the haskell project for xmonad
  -- setup_each_lsp('hls', true)

  -- cmake
  setup_each_lsp('cmake', {
    cmd = {vars.lsp_condaenv_bin..'cmake-language-server'},
  })

  -- python
  if vim.fn.executable('pylsp') == 1 then
    setup_each_lsp('pylsp', {
      single_file_support = false,
      root_dir = function(client)
        _ = client
        return vim.fn.getcwd()
      end,
      settings={
        pylsp={plugins={pycodestyle={maxLineLength=300}}}
      }
    })
  else
    if vim.fn.executable('pyright') == 1 then
      setup_each_lsp('pyright', true)
    end
  end

  -- -- verilog & systemverilog
  -- setup_each_lsp('svls', true)

  -- -- hdl
  -- setup_each_lsp('hdl_checker', true)

end

local alternative_lsp = function()
  setup_each_lsp('powershell_es', {
    cmd = {'powershell_es', '-Stdio'}
  })
end

return {
  general_lsp = general_lsp,
  setup_each_lsp = setup_each_lsp,
  alternative_lsp = alternative_lsp,
  -- construct_statusline = construct_statusline
}

-- vim:et ts=2 sw=2
