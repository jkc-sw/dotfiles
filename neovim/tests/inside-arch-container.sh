#!/usr/bin/env bash
set -euo pipefail
pacman -Syu --noconfirm neovim git curl chezmoi ripgrep fd gcc make unzip tree-sitter-cli luarocks lua51
# Arch's default Lua 5.5 cannot run luacheck 1.1.0. Mason invokes LuaRocks,
# so select the compatible runtime before Mason installs the Lua linter.
luarocks config --scope system lua_version 5.1
mkdir -p /root/.config /root/.local/share/jerry-dotfiles /tmp/chezmoi
cp -a /source/neovim /root/.local/share/jerry-dotfiles/
cp -a /chezmoi-source/. /tmp/chezmoi/
chezmoi --source /tmp/chezmoi --force apply /root/.config/nvim
mkdir -p /root/.local/state/omarchy/current/theme
printf 'return {}\n' > /root/.local/state/omarchy/current/theme/neovim.lua
printf 'export JERRY_DOTFILES=/root/.local/share/jerry-dotfiles\n' > /etc/profile.d/jerry-dotfiles.sh
export JERRY_DOTFILES=/root/.local/share/jerry-dotfiles
cd /tmp
nvim --version | head -2
nvim --headless -u NONE -l /source/neovim/tests/shared.lua
nvim --headless -u NONE -l /source/neovim/tests/legacy.lua
nvim --headless -u NONE -l /source/neovim/tests/perforce.lua
timeout 240 nvim --headless '+Lazy! restore' '+lua vim.wait(60000, function() return vim.fn.executable("luacheck") == 1 end, 100)' +qa
rm -f /tmp/jerry-lazyvim-result
timeout 120 nvim --headless '+lua vim.defer_fn(function() local ok, err = pcall(dofile, "/source/neovim/tests/lazyvim.lua"); if not ok then io.stderr:write(tostring(err), string.char(10)); vim.cmd("cquit 1") else vim.cmd("qa!") end end, 1000)'
cat /tmp/jerry-lazyvim-result
mkdir -p /root/workspace
printf 'local greeting={message="Hello from Arch LazyVim"}\nprint(greeting.message)\nprint(undefined_example) -- luacheck should flag this\n' > /root/workspace/sample.lua
printf '# Arch LazyVim journal\n\nUse the Markdown date abbreviations and custom mappings here.\n' > /root/workspace/journal.md
