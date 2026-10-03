#!/usr/bin/env bash
set -euo pipefail
repo=$(cd "$(dirname "$0")/../.." && pwd)
name=${NVIM_PREVIEW_NAME:-nvim-home-manager-ubuntu}
generation_link=${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager
if [[ ! -e "$generation_link" ]]; then
  generation_link=/nix/var/nix/profiles/per-user/${USER:-$(id -un)}/home-manager
fi
generation=$(readlink -f "$generation_link")
profile=$(readlink -f "$HOME/.nix-profile")
[[ -f "$generation/home-files/.config/nvim/init.lua" && -d "$generation/home-files/.local/share/nvim" && -x "$profile/bin/nvim" ]] || {
  echo 'An existing Home Manager generation with Neovim plugins and a Neovim user profile is required.' >&2
  exit 1
}
if docker container inspect "$name" >/dev/null 2>&1; then
  echo "Container $name already exists. Use docker exec, choose NVIM_PREVIEW_NAME, or explicitly remove it." >&2
  exit 1
fi
docker run -d --init --name "$name" -e TERM=xterm-256color -e NIX_REMOTE=local \
  -e "NVIM_HM_GENERATION=$generation" -e "NVIM_HM_PROFILE=$profile" \
  --mount "type=bind,src=$repo,dst=/source,readonly" \
  --mount 'type=bind,src=/nix,dst=/nix,readonly' \
  ubuntu:24.04 sleep infinity
docker exec "$name" bash /source/neovim/tests/inside-home-manager-container.sh
printf '\nReady: docker exec -it -w /root/workspace %s bash -l\n' "$name"
