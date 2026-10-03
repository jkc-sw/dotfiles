#!/usr/bin/env bash
set -euo pipefail
repo=$(cd "$(dirname "$0")/../.." && pwd)
chezmoi_source=$(realpath "${1:?Usage: start-arch.sh /path/to/dotfiles2026}")
name=${NVIM_PREVIEW_NAME:-nvim-lazyvim-arch}
if docker container inspect "$name" >/dev/null 2>&1; then
  echo "Container $name already exists. Use docker exec, choose NVIM_PREVIEW_NAME, or explicitly remove it." >&2
  exit 1
fi
docker run -d --init --name "$name" -e TERM=xterm-256color \
  --mount "type=bind,src=$repo,dst=/source,readonly" \
  --mount "type=bind,src=$chezmoi_source,dst=/chezmoi-source,readonly" \
  archlinux:latest sleep infinity
docker exec "$name" bash /source/neovim/tests/inside-arch-container.sh
printf '\nReady: docker exec -it -w /root/workspace %s bash -l\n' "$name"
