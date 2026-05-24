#!/usr/bin/env bash
# ============================================================================
# zoxide-jump.sh - Zoxide directory picker for tmux
# ============================================================================
# This script uses fzf to select from zoxide database and creates or switches
# to a tmux session based on the selected directory.
# ============================================================================

set -euo pipefail

# Check if zoxide is installed
if ! command -v zoxide &> /dev/null; then
    echo "Error: zoxide is not installed"
    echo "Install it from: https://github.com/ajeetdsouza/zoxide"
    exit 1
fi

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "Error: fzf is not installed"
    echo "Install it from: https://github.com/junegunn/fzf"
    exit 1
fi

# Check if tmux is running
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is not installed"
    exit 1
fi

# Get the directory from zoxide database using fzf
# Shows directory name and path for better selection
selected_dir=$(zoxide query -l | fzf \
    --height=100% \
    --border=rounded \
    --prompt="Zoxide> " \
    --preview="ls -la {}" \
    --preview-window=right:50%:wrap \
    --bind="ctrl-d:reload(zoxide query -l)" \
    --header="Enter: Select | Ctrl-d: Refresh | Esc: Cancel")

# If no selection made, exit silently
if [[ -z "$selected_dir" ]]; then
    exit 0
fi

# Get the directory name for session naming
session_name=$(basename "$selected_dir" | tr '.:' '_')

# Check if session already exists
if tmux has-session -t "$session_name" 2>/dev/null; then
    # Session exists, switch to it
    if [[ -n "${TMUX:-}" ]]; then
        # We're inside tmux, switch client
        tmux switch-client -t "$session_name"
    else
        # We're outside tmux, attach to session
        tmux attach-session -t "$session_name"
    fi
else
    # Session doesn't exist, create new one
    if [[ -n "${TMUX:-}" ]]; then
        # We're inside tmux, create new session and switch
        tmux new-session -d -s "$session_name" -c "$selected_dir"
        tmux switch-client -t "$session_name"
    else
        # We're outside tmux, create and attach
        tmux new-session -s "$session_name" -c "$selected_dir"
    fi
fi
