# Keybindings Reference Card

> Quick reference for tmux-i3-workflow keybindings

## Modifier Key

All keybindings use **Alt** (Meta) as the modifier key, matching i3wm's `$mod` behavior.

```
Modifier: Alt (M-)
No prefix mode - direct key binding
```

---

## Navigation

### Pane Focus

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + h` | Focus Left | Move focus to pane on the left |
| `Alt + j` | Focus Down | Move focus to pane below |
| `Alt + k` | Focus Up | Move focus to pane above |
| `Alt + l` | Focus Right | Move focus to pane on the right |

### Window Switching

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + 1` | Window 1 | Switch to window 1 |
| `Alt + 2` | Window 2 | Switch to window 2 |
| `Alt + 3` | Window 3 | Switch to window 3 |
| `Alt + 4` | Window 4 | Switch to window 4 |
| `Alt + 5` | Window 5 | Switch to window 5 |
| `Alt + 6` | Window 6 | Switch to window 6 |
| `Alt + 7` | Window 7 | Switch to window 7 |
| `Alt + 8` | Window 8 | Switch to window 8 |
| `Alt + 9` | Window 9 | Switch to window 9 |
| `Alt + 0` | Window 10 | Switch to window 10 |

---

## Pane Management

### Creation & Layout

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + \` | Split Horizontal | Create horizontal split |
| `Alt + -` | Split Vertical | Create vertical split |
| `Alt + =` | Popup Terminal | Open popup in current directory |
| `Alt + s` | Main-Horizontal | Switch to main-horizontal layout |
| `Alt + Shift + v` | Even-Vertical | Switch to even-vertical layout |
| `Alt + Shift + s` | Even-Horizontal | Switch to even-horizontal layout |
| `Alt + Shift + t` | Tiled | Switch to tiled layout |
| `Alt + z` | Zoom Toggle | Toggle pane fullscreen |

### Layout Preview

```
even-vertical (M-S-v):      main-horizontal (M-s):
┌──────────┬──────┐        ┌──────────────────────┐
│          │      │        │                      │
│  Pane 1  │Pane 2│        │        Main          │
│  (50%)   │(50%) │        │        (60%)         │
│          │      │        ├──────────────────────┤
│          │      │        │   Pane  │   Pane    │
└──────────┴──────┘        │  (40%)  │   (40%)   │
                            └─────────────────────┘
```

### Closing

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + d` | Kill Pane | Close current pane |

---

## Pane Movement

### Swap Panes

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + Shift + h` | Swap Left | Swap with pane on the left |
| `Alt + Shift + j` | Swap Down | Swap with pane below |
| `Alt + Shift + k` | Swap Up | Swap with pane above |
| `Alt + Shift + l` | Swap Right | Swap with pane on the right |

### Move to Window

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + Shift + 0` | Move to Window 10 | Move current pane to window 10 |

---

## Session Management

### Session Switcher

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + f` | Session Popup | Open fuzzy session switcher |
| `Alt + Space` | Sessionx | Sessionx fuzzy finder |
| `Alt + i` | Last Session | Switch to last used session |

### Zoxide Integration

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + g` | Zoxide Popup | Open zoxide directory picker |

### Utilities

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + e` | Capture Edit | Capture and edit command output |

### Session Persistence

Sessions are automatically saved every 15 minutes and restored when tmux starts.

---

## Window Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + Tab` | Last Window | Switch to last active window |
| `Alt + Left` | Previous Window | Switch to previous window |
| `Alt + Right` | Next Window | Switch to next window |

---

## Copy Mode

### Enter/Exit

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + Up` | Enter Copy | Enter copy mode and scroll up |
| `Alt + Down` | Enter Copy | Enter copy mode |
| `Alt + PageUp` | Enter Copy | Enter copy mode and page up |
| `Enter` | Enter Copy | Enter copy mode |
| `i / a / q / Escape` | Exit Copy | Exit copy mode |

### Navigation (Copy Mode)

| Keybinding | Action |
|------------|--------|
| `h/j/k/l` | Move cursor |
| `w` | Word forward |
| `b` | Word backward |
| `0` | Line start |
| `$` | Line end |
| `Ctrl+u` | Half page up |
| `Ctrl+d` | Half page down |
| `Ctrl+b` | Full page up |
| `Ctrl+f` | Full page down |
| `g` | Go to top |
| `G` | Go to bottom |

### Selection & Yank

| Keybinding | Action | Description |
|------------|--------|-------------|
| `v` | Visual Start | Start visual selection |
| `V` | Visual Line | Select entire line |
| `Ctrl+v` | Visual Block | Block selection |
| `y` | Yank | Copy to system clipboard |
| `Enter` | Yank | Copy to system clipboard |

### Paste

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + p` | Paste | Paste from tmux buffer |

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│                    tmux-i3-workflow                          │
├─────────────────────────────────────────────────────────────┤
│  NAVIGATION          │  PANE MGMT         │  SESSION        │
│  ─────────────       │  ────────────      │  ──────────     │
│  Alt+h/j/k/l  Focus  │  Alt+\  Split H    │  Alt+f  Switch  │
│  Alt+0-9      Window │  Alt+-  Split V    │  Alt+g  Zoxide  │
│  Alt+Tab      Last   │  Alt+=  Popup      │  Alt+e  Capture │
│  Alt+←/→      Prev/  │  Alt+s   Main-H    │  Alt+i  Last    │
│               Next   │  Alt+S-v Even-V    │                 │
│                      │  Alt+S-s Even-H    │  CLOSE          │
│  PANE MOVE           │  Alt+S-t Tiled     │  ──────         │
│  ──────────          │  Alt+z   Zoom      │  Alt+d  Kill    │
│  Alt+Shift+hjkl Swap │  Alt+d   Kill      │                 │
│  Alt+Shift+0   Move  │                    │                 │
└─────────────────────────────────────────────────────────────┘
```

---

## Tips

1. **Quick Window Switch**: Use `Alt+1` through `Alt+9` for instant window access
2. **Zoom Focus**: Press `Alt+z` to focus on a single pane, press again to restore
3. **Layout Switching**: `Alt+s` for main-horizontal, `Alt+Shift+v` for even-vertical
4. **Session Jump**: `Alt+f` shows all sessions with fuzzy search
5. **Project Jump**: `Alt+g` uses zoxide for smart project switching
6. **Window Cycling**: `Alt+Left/Right` to cycle through windows, `Alt+Tab` for last window
