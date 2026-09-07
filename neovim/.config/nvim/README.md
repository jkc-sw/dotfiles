# Lua tooling

This Neovim configuration uses:

- [StyLua](https://github.com/JohnnyMorganz/StyLua) for formatting;
- [Luacheck](https://github.com/lunarmodules/luacheck) for linting; and
- `lua-language-server` plus `lazydev.nvim` for Neovim API completion and type information.

Install `stylua`, `luacheck`, and `lua-language-server` through your system or
Home Manager package configuration. StyLua formats Lua buffers before they are
written; Luacheck publishes diagnostics on buffer entry and after each write.

Use `:LuaFormat` or `:LuaLint` to run either action manually. The project
policies live in `.stylua.toml` and `.luacheckrc`.
