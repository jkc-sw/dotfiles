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
require('perforce').setup({ key_prefix = '<localleader>p' })
```

This enables custom helpers, filetype support, and `:ArgsToQF` while leaving
LazyVim in charge of global options, picker and LSP mappings, formatting, and
yank highlighting. In particular, it preserves LazyVim's sign column, undo
directory, clipboard, grep command, and formatting toggles. Call setup once,
before opening files, and choose the integration at that point.

Perforce uses `<localleader>p` in the LazyVim spec (for example,
`<localleader>po` lists opened files). Its default `<leader>e` prefix remains
available to Home Manager.

The default personal key namespace is `<leader>a`; each key below follows
`<leader>`:

| Keys | Action |
| --- | --- |
| `asl`, `asv` | Source marked Lua or Vimscript blocks |
| `ael`, `aev` | Evaluate line or visual selection as Lua or Vimscript |
| `am` | Jump to a personal marker |
| `aT` | Send line or visual selection to a Neovim terminal |
| `ate`, `ato` | Send line or selection to next/previous tmux pane |
| `atu`, `ata` | Send text block to next/previous tmux pane |
| `at.`, `at,` | Send word to next/previous tmux pane |
| `ad[`, `ad]` | Previous/next Markdown journal heading |
| `ady` | Yank fenced Markdown code |
| `adt`, `adn`, `adf`, `adh` | Copy multiline, single-line, Vim, or shell jump snippet |
| `adu`, `adb`, `adU` | Insert timestamp, insert break, or copy line into journal |
| `ada` | Format Markdown table or visual selection |

Markdown mappings and abbreviations are buffer-local. Tmux helpers require
`tmux` and a reachable server. Markdown origin tags require `uuidgen` and
`rg`; table alignment requires `tr` and a `column` version supporting `-o`.
Missing or failed table commands leave the text intact. Optional Jira lookup
requires `jfssh`, `BOXX_IP`, and `BOXX_USER` (or PowerShell and `MyModules00`'s
`jf` on Windows); unavailable helpers report a message when invoked.

Home Manager automatically enables the legacy personal options and mappings.
Other integrators can explicitly request them with
`require('jerry').setup({ features = { legacy = true } })`; this profile also
enables the bespoke Lua tools and expects the plugins used by legacy mappings
(such as Telescope, Undotree, and Tabular) to be installed separately.

## Lua tooling

The Home Manager/legacy profile uses:

- [StyLua](https://github.com/JohnnyMorganz/StyLua) for formatting;
- [Luacheck](https://github.com/lunarmodules/luacheck) for linting; and
- `lua-language-server` plus `lazydev.nvim` for Neovim API completion and type
  information.

Install the executables through Home Manager or mise. LazyVim integrations
should use their native Conform, nvim-lint, and language extras instead. StyLua formats Lua
buffers before they are written; Luacheck publishes diagnostics on buffer
entry and after each write. Use `:LuaFormat` or `:LuaLint` to run either action
manually. Project policies live in `.stylua.toml` and `.luacheckrc`.
