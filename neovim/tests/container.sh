#!/usr/bin/env bash
set -euo pipefail

# All installs, generated config, lockfile writes and editor state stay in the container.
repo=$(cd "$(dirname "$0")/../.." && pwd)
chezmoi_source=${1:?Usage: container.sh /path/to/dotfiles2026}
docker run --rm --init \
  --mount "type=bind,src=$repo,dst=/source,readonly" \
  --mount "type=bind,src=$(realpath "$chezmoi_source"),dst=/chezmoi-source,readonly" \
  ubuntu:24.04 bash /source/neovim/tests/inside-container.sh
