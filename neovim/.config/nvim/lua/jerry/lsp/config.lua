local M = {}
local lspconfig = require 'lspconfig'
local vim = vim

local capabilities = require('blink.cmp').get_lsp_capabilities()

local function findLatestMatlabInstall()
  local matlabInstallationDir = '/usr/local/MATLAB'
  local iter = vim.fs.dir(matlabInstallationDir)
  local versions = {}
  for name, type in iter do
    if type == 'directory' and string.find(name, 'R20') ~= nil then
      table.insert(versions, vim.fs.joinpath(matlabInstallationDir, name))
    end
  end
  if #versions == 0 then
    return nil
  end
  table.sort(versions)
  return versions[#versions]
end

--- @brief Setup an lsp source with options
--- @param target string the lsp name
--- @param opt? table|boolean
local function setup_each_lsp(target, opt)
  if not opt then
    return
  end

  if type(opt) ~= 'table' then
    opt = {}
  end

  opt = vim.tbl_deep_extend("force", {
    capabilities = capabilities,
  }, opt)

  lspconfig[target].setup(opt)
end

--- @brief setup all the lsp
M.setup = function()
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
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path..'/.luarc.json') or vim.uv.fs_stat(path..'/.luarc.jsonc')) then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          -- Tell the language server which version of Lua you're using
          -- (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT'
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            -- vim.fn.expand('~/repos/avante.nvim')
            -- Depending on the usage, you might want to add additional paths here.
            -- "${3rd}/luv/library"
            -- "${3rd}/busted/library",
          }
          -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
          -- library = vim.api.nvim_get_runtime_file("", true)
        }
      })
    end,
    settings = {
      Lua = {}
    }
  })

  -- go
  setup_each_lsp('gopls', true)
  setup_each_lsp('golangci_lint_ls', true)

  -- json
  setup_each_lsp('jsonls', true)

  -- matlab
  setup_each_lsp('matlab_ls', {
    settings = {
      MATLAB = {
        indexWorkspace = true,
        installPath = findLatestMatlabInstall(),
        matlabConnectionTiming = 'onStart',
        telemetry = false,
      },
    }
  })

  -- bash
  setup_each_lsp('bashls', true)

  -- groovy
  setup_each_lsp('groovyls', {
    cmd = { 'groovy-language-server' },
    root_dir = function(_)
      -- fname is the filename of the buffer being attached.
      -- We ignore it here and just return the current working directory.
      return vim.fn.getcwd()
    end,
  })

  -- nix
  -- Need to do some special configuration
  -- Missing range token handling in neovim: https://github.com/neovim/neovim/issues/23026
  -- Known performance issue in Nil: https://github.com/oxalica/nil/issues/83
  setup_each_lsp('nil_ls', true)
  -- setup_each_lsp('nixd', true)

  -- docker
  setup_each_lsp('dockerls', true)

  -- texlab
  setup_each_lsp('texlab', true)

  -- yaml
  setup_each_lsp('yamlls', true)

  -- ts_ls
  setup_each_lsp('ts_ls', true)

  -- -- haskell -- Cannot get it to work, not sure how to handle the import/setup the haskell project for xmonad
  -- setup_each_lsp('hls', true)

  -- cmake
  setup_each_lsp('cmake', true)

  -- java
  setup_each_lsp('jdtls', {
    cmd = { 'jdtls' },
  })

  -- python
  setup_each_lsp('ruff', {
    init_options = {
      settings = {
        -- Any extra CLI arguments for `ruff` go here.
        args = {},
      }
    }
  })

  if vim.fn.executable('pylsp') == 1 then
    setup_each_lsp('pylsp', {
      single_file_support = false,
      root_dir = function(client)
        _ = client
        return vim.fn.getcwd()
      end,
      settings = {
        pylsp = { plugins = { pycodestyle = { maxLineLength = 300 } } }
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

  if vim.fn.executable('power_es_work.sh') == 1 then
    setup_each_lsp('powershell_es', {
      cmd = { 'power_es_work.sh' }
    })
  else
    setup_each_lsp('powershell_es', {
      cmd = { 'powershell_es', '-Stdio' }
    })
  end

  -- Sonarlint
  require('sonarlint').setup({
    server = {
      cmd = { 'sonarlint-ls' },
      -- All settings are optional
      -- settings = {
      --   -- The default for sonarlint is {}, this is just an example
      --   sonarlint = {
      --     rules = {
      --       ['typescript:S101'] = { level = 'on', parameters = { format = '^[A-Z][a-zA-Z0-9]*$' } },
      --       ['typescript:S103'] = { level = 'on', parameters = { maximumLineLength = 180 } },
      --       ['typescript:S106'] = { level = 'on' },
      --       ['typescript:S107'] = { level = 'on', parameters = { maximumFunctionParameters = 7 } }
      --     }
      --   }
      -- }
    },
    filetypes = {
      'python',
      'cpp',
    }
  })
end

return M
