-- Neovim exposes a dynamic `vim` API.  Its proxy tables intentionally allow
-- assignments such as `vim.g.foo` and `vim.opt.number`, which Luacheck's
-- ordinary read-only global handling would incorrectly flag.
std = "luajit"
read_globals = { "vim" }
globals = {
  "P",
  "R",
  "RELOAD",
  "S",
  "SL",
  "SV",
  "RT",
  "RS",
  "RV",
}
ignore = { "122" }
max_line_length = 120
