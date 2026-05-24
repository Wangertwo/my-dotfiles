# tmux-i3-workflow

> **i3wm-style tmux configuration** - Bringing familiar i3wm keybindings and workflow to terminal multiplexing.

[![tmux](https://img.shields.io/badge/tmux-3.2%2B-blue.svg)](https://github.com/tmux/tmux)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

**tmux-i3-workflow** is a tmux configuration preset designed for i3wm users who want consistent keybindings across GUI and terminal environments. It eliminates the learning curve for tmux by using direct Alt-modified keys (no `Ctrl+b` prefix), preserving your i3wm muscle memory.

### Key Features

- **No Prefix Mode** - Direct Alt-modified keys, just like i3wm
- **Vim-style Navigation** - `h/j/k/l` for pane movement
- **Session Management** - Fuzzy session switching with popup UI
- **Zoxide Integration** - Jump to projects quickly
- **Session Persistence** - Auto-save and restore sessions
- **OSC 52 Clipboard** - System clipboard integration over SSH
- **Catppuccin Theme** - Beautiful, minimal status bar

## Quick Start

```bash
# 1. Clone the repository
git clone <repo-url> ~/.config/tmux-i3-workflow
cd ~/.config/tmux-i3-workflow

# 2. Run the installer
./install.sh

# 3. Start tmux and install plugins
tmux new -s my-project
# Press Alt+I to install plugins

# 4. Done! Start using i3-style keybindings
```

## Prerequisites

### Required

| Dependency | Version | Purpose |
|------------|---------|---------|
| **tmux** | 3.2+ | Terminal multiplexer |
| **fzf** | any | Fuzzy finder for session switcher |
| **TPM** | latest | Tmux Plugin Manager |

### Recommended

| Dependency | Purpose |
|------------|---------|
| **zoxide** | Smart directory jumping |
| **Kitty/Alacritty/iTerm2/Foot** | Terminal with OSC 52 clipboard support |

### Terminal Compatibility

OSC 52 clipboard support is required for copy/paste functionality:

| Terminal | OSC 52 Support | Notes |
|----------|---------------|-------|
| Kitty | ✅ Yes | Default enabled |
| Alacritty | ✅ Yes | Requires config |
| iTerm2 | ✅ Yes | Default enabled |
| Foot | ✅ Yes | Wayland native |
| Ghostty | ✅ Yes | Default enabled |
| WezTerm | ⚠️ Partial | Copy works, paste limited |

## Installation

### Option 1: Automated Installation

```bash
# Clone and run installer
git clone <repo-url> ~/.config/tmux-i3-workflow
~/.config/tmux-i3-workflow/install.sh
```

### Option 2: Manual Installation

```bash
# 1. Clone repository
git clone <repo-url> ~/.config/tmux-i3-workflow

# 2. Install TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# 3. Create symlink
ln -s ~/.config/tmux-i3-workflow/.tmux.conf ~/.tmux.conf

# 4. Copy scripts
mkdir -p ~/.config/tmux/scripts
cp ~/.config/tmux-i3-workflow/scripts/*.sh ~/.config/tmux/scripts/
chmod +x ~/.config/tmux/scripts/*.sh

# 5. Start tmux and install plugins
tmux new -s test
# Press Alt+I
```

## Keybindings Reference

### Navigation

| Keybinding | Action |
|------------|--------|
| `Alt + h` | Focus left pane |
| `Alt + j` | Focus down pane |
| `Alt + k` | Focus up pane |
| `Alt + l` | Focus right pane |
| `Alt + 0-9` | Switch to window 0-9 |

### Pane Management

| Keybinding | Action |
|------------|--------|
| `Alt + \` | Split horizontal |
| `Alt + -` | Split vertical |
| `Alt + =` | Popup terminal in current path |
| `Alt + s` | Main-horizontal layout |
| `Alt + Shift + v` | Even-vertical layout |
| `Alt + Shift + s` | Even-horizontal layout |
| `Alt + Shift + t` | Tiled layout |
| `Alt + z` | Toggle fullscreen (zoom) |
| `Alt + d` | Kill current pane |

### Pane Movement

| Keybinding | Action |
|------------|--------|
| `Alt + Shift + h` | Swap pane left |
| `Alt + Shift + j` | Swap pane down |
| `Alt + Shift + k` | Swap pane up |
| `Alt + Shift + l` | Swap pane right |
| `Alt + Shift + 0` | Move pane to window 10 |

### Session Management

| Keybinding | Action |
|------------|--------|
| `Alt + f` | Open session switcher popup |
| `Alt + g` | Open zoxide directory picker |
| `Alt + e` | Capture and edit command output |
| `Alt + i` | Switch to last used session |
| `Alt + Space` | Sessionx fuzzy finder |

### Window Navigation

| Keybinding | Action |
|------------|--------|
| `Alt + 0-9` | Switch to window 0-9 |
| `Alt + Tab` | Switch to last window |
| `Alt + Left` | Switch to previous window |
| `Alt + Right` | Switch to next window |

### Copy Mode

| Keybinding | Action |
|------------|--------|
| `Alt + Up` | Enter copy mode and scroll up |
| `Alt + Down` | Enter copy mode |
| `Alt + PageUp` | Enter copy mode and page up |
| `Enter` | Enter copy mode |
| `Alt + p` | Paste from buffer |

#### Inside Copy Mode

| Keybinding | Action |
|------------|--------|
| `v` | Start visual selection |
| `V` | Select line |
| `Ctrl + v` | Block selection |
| `y` | Yank to system clipboard |
| `i / a / q / Escape` | Exit copy mode |

## Plugin List

| Plugin | Purpose |
|--------|---------|
| [TPM](https://github.com/tmux-plugins/tpm) | Plugin Manager |
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Sensible defaults |
| [tmux-tilish](https://github.com/jabirali/tmux-tilish) | i3wm keybindings |
| [tmux-sessionx](https://github.com/omerxx/tmux-sessionx) | Fuzzy session management |
| [catppuccin/tmux](https://github.com/catppuccin/tmux) | Catppuccin Mocha theme |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Session persistence |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto-save sessions |

## Configuration Highlights

### Zero Escape Delay

Critical for Vim/Neovim users:

```conf
set -s escape-time 0
```

### OSC 52 Clipboard

Works over SSH when terminal supports it:

```conf
set -g set-clipboard on
set -g allow-passthrough on
```

### Session Persistence

Auto-save every 15 minutes and restore on start:

```conf
set -g @continuum-restore "on"
set -g @continuum-save-interval "15"
```

## Project Structure

```
tmux-i3-workflow/
├── .tmux.conf              # Main configuration file
├── README.md               # This file
├── install.sh              # Installation script
├── scripts/
│   ├── zoxide-jump.sh      # Zoxide directory picker
│   └── session-switcher.sh # Session switcher wrapper
└── docs/
    ├── keybindings.md      # Detailed keybinding reference
    └── workflow.md         # Example workflows & tips
```

## Troubleshooting

### Plugins not installing

1. Ensure TPM is installed: `ls ~/.tmux/plugins/tpm`
2. Press `Alt+I` inside tmux (or `Ctrl+b` then `I`)
3. Check for errors in tmux messages: `tmux show-messages`

### Keybindings not working

1. Verify plugins are installed: `ls ~/.tmux/plugins/`
2. Reload configuration: `tmux source ~/.tmux.conf`
3. Check keybindings: `tmux list-keys | grep M-`

### Clipboard not working

1. Verify terminal supports OSC 52
2. Check settings: `tmux show -g | grep clipboard`
3. For Alacritty, add to config:
   ```yaml
   terminal:
     osc52: CopyPaste
   ```

### Escape key delay in Vim

1. Verify escape time setting: `tmux show -gs escape-time`
2. Should show: `escape-time 0`

### Session not restoring

1. Verify resurrect/continuum plugins are installed
2. Check continuum status: `tmux show -g @continuum-restore`
3. Manual restore: `Ctrl+b` then `Ctrl+r`

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [tmux-tilish](https://github.com/jabirali/tmux-tilish) for the excellent i3wm integration
- [Catppuccin](https://github.com/catppuccin) for the beautiful color scheme
- All plugin authors for their amazing work

---

**Happy coding!** 🚀
