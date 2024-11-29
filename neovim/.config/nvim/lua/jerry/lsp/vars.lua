
-- some constant
return {
  luals_repos = (vim.uv or vim.loop).os_homedir()..'/repos/lua-language-server/',
  lsp_condaenv_bin = (vim.uv or vim.loop).os_homedir()..'/miniconda3/envs/dev_env_ansible/bin/',
  pses_bundle_path = vim.env.HOME..'/repos/PowerShellEditorServices/module'
}

-- vim:et ts=2 sw=2
