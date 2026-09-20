# Neovim configuration

The custom configuration lives in the `jerry` and `perforce` plugins and
supports two integrators. Loading either plugin module alone has no effect; an
integrator must call its `.setup()` function.

## Home Manager

Home Manager provides Neovim, language servers, and third-party plugins. The
root `init.lua` is the Home Manager entrypoint and enables the corresponding
feature explicitly:

```lua
require('jerry').setup {
  features = {
    home_manager = true,
  },
}

require('perforce').setup()
```

This feature owns all configuration under `jerry.plugins-cfg`, the custom LSP
configuration, the colorscheme, and the Tree-sitter integration. It expects
those plugins and executables to have been installed by Home Manager.

## LazyVim

LazyVim owns third-party plugins and LSP servers through lazy.nvim and Mason;
mise provides standalone executables. `lua/plugins/jerry.lua` is a LazyVim
plugin spec that loads both local plugins and calls their setup functions. The
shared `jerry` plugin is configured without the Home Manager feature:

```lua
require('jerry').setup()
require('perforce').setup()
```

This enables the shared custom options, keymaps, autocommands, filetype
support, and Lua utilities without applying the Home Manager plugin or LSP
configuration.

## Lua tooling

The shared configuration uses:

- [StyLua](https://github.com/JohnnyMorganz/StyLua) for formatting;
- [Luacheck](https://github.com/lunarmodules/luacheck) for linting; and
- `lua-language-server` plus `lazydev.nvim` for Neovim API completion and type
  information.

Install the executables through Home Manager or mise. StyLua formats Lua
buffers before they are written; Luacheck publishes diagnostics on buffer
entry and after each write. Use `:LuaFormat` or `:LuaLint` to run either action
manually. Project policies live in `.stylua.toml` and `.luacheckrc`.
