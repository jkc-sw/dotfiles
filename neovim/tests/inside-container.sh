#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq ca-certificates curl git xz-utils unzip ripgrep build-essential python3 luarocks >/dev/null
curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz -o /tmp/nvim.tar.gz
tar -xzf /tmp/nvim.tar.gz -C /opt
export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
curl -fsSL https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz -o /tmp/tree-sitter.gz
gzip -dc /tmp/tree-sitter.gz > /usr/local/bin/tree-sitter
chmod +x /usr/local/bin/tree-sitter
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b /usr/local/bin >/dev/null
mkdir -p /root/.config /root/.local/share/jerry-dotfiles /tmp/chezmoi
cp -a /source/neovim /root/.local/share/jerry-dotfiles/
cp -a /chezmoi-source/. /tmp/chezmoi/
# Render only Neovim, including chezmoi's symlink_ and dot_ attributes.
# The unpublished shared plugin is supplied from this worktree above.
chezmoi --source /tmp/chezmoi --force apply /root/.config/nvim
# Omarchy generates this symlink target outside chezmoi. Supply an empty theme
# spec in the fixture so the container uses LazyVim's bundled fallback theme.
mkdir -p /root/.local/state/omarchy/current/theme
printf 'return {}\n' > /root/.local/state/omarchy/current/theme/neovim.lua
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
