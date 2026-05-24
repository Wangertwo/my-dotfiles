#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_suffix="backup-$(date +%Y%m%d%H%M%S)"

backup_path() {
    local target="$1"

    if [ -L "$target" ]; then
        rm "$target"
    elif [ -e "$target" ]; then
        mv "$target" "$target.$backup_suffix"
    fi
}

link_config() {
    local name="$1"
    local source="$repo_dir/.config/$name"
    local target="$HOME/.config/$name"

    mkdir -p "$HOME/.config"
    backup_path "$target"
    ln -s "$source" "$target"
}

link_config fish
link_config nvim
link_config tmux

if [ -f "$repo_dir/.config/tmux/.tmux.conf" ]; then
    backup_path "$HOME/.tmux.conf"
    ln -s "$repo_dir/.config/tmux/.tmux.conf" "$HOME/.tmux.conf"
fi

printf 'Dotfiles installed from %s\n' "$repo_dir"
