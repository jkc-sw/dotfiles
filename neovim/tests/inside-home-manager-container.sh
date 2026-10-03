#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq git ca-certificates python3 >/dev/null
# Refreshes run in a non-login shell. Recover the container's original resolved
# generation/profile paths, including for previews created before the launchers.
if [[ -f /etc/profile.d/nvim-preview.sh ]]; then
  source /etc/profile.d/nvim-preview.sh
fi
: "${NVIM_HM_GENERATION:?Launch with start-home-manager.sh}"
: "${NVIM_HM_PROFILE:?Launch with start-home-manager.sh}"
mkdir -p /root/.config /root/.local/share /root/.vim/undodir /usr/local/MATLAB /root/workspace
ln -sfn "$NVIM_HM_PROFILE" /root/.nix-profile
ln -sfn /source /root/.local/share/jerry-dotfiles
cp -a "$NVIM_HM_GENERATION/home-files/.local/share/nvim/." /root/.local/share/nvim/
cp -a /source/neovim/.config/nvim/. /root/.config/nvim/
python3 - <<'PY'
import os
from pathlib import Path
source = Path(os.environ['NVIM_HM_GENERATION']) / 'home-files/.config/nvim/init.lua'
target = Path('/root/.config/nvim/init.lua')
worktree_init = target.read_text()
preamble = []
for line in source.read_text().splitlines():
    if line.startswith(('package.path =', 'package.cpath =', 'vim.g.loaded_')):
        preamble.append(line)
if not any(line.startswith('package.path =') for line in preamble):
    raise SystemExit('Generated Home Manager init has no recognizable Lua package preamble')
target.write_text('\n'.join(preamble) + '\nvim.opt.packpath:prepend("/root/.config/nvim")\n' + worktree_init)
PY
cat > /etc/profile.d/nvim-preview.sh <<'PROFILE'
export PATH=/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH
export JERRY_DOTFILES=/root/.local/share/jerry-dotfiles
export TERM=xterm-256color
export NIX_REMOTE=local
PROFILE
# Keep these paths inside the preview; never activate or update a host profile.
printf 'export NVIM_HM_GENERATION=%q\nexport NVIM_HM_PROFILE=%q\n' \
  "$NVIM_HM_GENERATION" "$NVIM_HM_PROFILE" >> /etc/profile.d/nvim-preview.sh
source /etc/profile.d/nvim-preview.sh
printf 'local greeting={message="Hello from Home Manager"}\nprint(greeting.message)\nprint(undefined_example) -- luacheck should flag this\n' > /root/workspace/sample.lua
printf '# Home Manager journal\n\nTry the Markdown date abbreviations and custom mappings here.\n' > /root/workspace/journal.md
printf '{"workspace.checkThirdParty":false}\n' > /root/workspace/.luarc.json
cd /tmp
nvim --version | head -2
for test in shared legacy perforce; do
  nvim --headless -u NONE -l "/source/neovim/tests/$test.lua"
done
for test in home-manager file-picker; do
  rm -f "/tmp/jerry-$test-result"
  timeout 120 nvim --headless "+lua vim.defer_fn(function() local ok, err = pcall(dofile, '/source/neovim/tests/$test.lua'); if not ok then io.stderr:write(tostring(err), string.char(10)); vim.cmd('cquit 1') else vim.cmd('qa!') end end, 1000)"
  cat "/tmp/jerry-$test-result"
done
