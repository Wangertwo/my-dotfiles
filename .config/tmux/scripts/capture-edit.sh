#!/usr/bin/env bash
# Capture all content in current tmux pane and edit in default editor popup

set -euo pipefail

pane_id="${1:-}"

temp_file=$(mktemp)

# Capture ALL content (including scrollback) from specified pane
if [[ -n "$pane_id" ]]; then
    tmux capture-pane -t "$pane_id" -p -S - -E - > "$temp_file"
else
    tmux capture-pane -p -S - -E - > "$temp_file"
fi

# Remove trailing empty lines
sed -i -e :a -e '/^[[:space:]]*$/{$d;N;};/\n$/ba' "$temp_file"

# Open in popup window with nvim, cleanup on exit
tmux popup -E -w 80% -h 80% "nvim '$temp_file' +\\\$; rm -f '$temp_file'"
