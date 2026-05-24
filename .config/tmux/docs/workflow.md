# Workflow Examples

> Practical examples for using tmux-i3-workflow in daily development

## Table of Contents

1. [Starting a New Project Session](#starting-a-new-project-session)
2. [Switching Between Projects](#switching-between-projects)
3. [Working with Multiple Windows](#working-with-multiple-windows)
4. [Using Zoxide Integration](#using-zoxide-integration)
5. [Session Persistence](#session-persistence)
6. [Advanced Workflows](#advanced-workflows)

---

## Starting a New Project Session

### Scenario
You're starting work on a new project and want to set up a dedicated tmux session.

### Steps

```bash
# 1. Create a new session with project name
tmux new -s my-project

# 2. Your default layout is main-vertical (editor left, terminal right)
# Start your editor in the main (left) pane
vim .

# 3. Navigate to right pane to run commands
Alt+l

# 4. Run your development server, tests, etc.
npm run dev
```

### Alternative: Using Zoxide

```bash
# If you've added the project directory to zoxide
z add ~/projects/my-project

# Then in tmux, press Alt+o to quickly jump to it
# This creates a session named after the directory
```

---

## Switching Between Projects

### Scenario
You're working on multiple projects and need to context-switch quickly.

### Using Session Switcher (Alt+d)

```
┌─────────────────────────────────────────────────────────────┐
│ > api-server                                              │
│   frontend-app                                            │
│   database-migrations                                      │
│   documentation                                            │
│                                                            │
│ Preview: [api-server session layout preview]               │
└─────────────────────────────────────────────────────────────┘
```

1. Press `Alt+d` to open the session switcher popup
2. Type to fuzzy search for your session
3. Press `Enter` to switch

### Benefits
- No need to remember exact session names
- Preview helps confirm you're switching to the right session
- Popup doesn't disrupt your current layout

---

## Working with Multiple Windows

### Scenario
You want to organize different tasks into separate windows within a session.

### Typical Project Layout

```
Window 1: Editor (Alt+1)
┌──────────────────────────────────────────────────────────────┐
│  vim/nvim running with your code                             │
│                                                              │
│                                                              │
│                                                              │
└──────────────────────────────────────────────────────────────┘

Window 2: Terminal (Alt+2)
┌──────────────────────────────────────────────────────────────┐
│  $ npm run dev                                               │
│  Server running on http://localhost:3000                     │
│                                                              │
└──────────────────────────────────────────────────────────────┘

Window 3: Git (Alt+3)
┌──────────────────────────────────────────────────────────────┐
│  $ git status                                                │
│  $ lazygit                                                   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Creating Windows

```bash
# While in tmux, create a new window
# tmux-tilish handles this - typically Alt+Enter creates panes
# For new windows, use the prefix: Ctrl+b c (or configure a direct binding)

# Quick switch between windows
Alt+1    # Editor
Alt+2    # Dev server
Alt+3    # Git operations
```

### Moving Panes Between Windows

```bash
# If you have a pane in window 1 that should be in window 2
# Press Alt+Shift+2 to move current pane to window 2
```

---

## Using Zoxide Integration

### Scenario
You frequently switch between many project directories and want smart directory jumping.

### Setup

```bash
# Add your commonly used directories to zoxide
z add ~/projects/frontend
z add ~/projects/backend
z add ~/work/client-a
z add ~/work/client-b
z add ~/personal/ dotfiles
```

### Daily Usage

```
1. Press Alt+o anywhere in tmux

┌─────────────────────────────────────────────────────────────┐
│ Zoxide>                                                     │
│   frontend                                                  │
│   backend                                                   │
│   client-a                                                  │
│   client-b                                                  │
│   dotfiles                                                  │
│                                                             │
│ Preview: [ls -la ~/projects/frontend]                       │
└─────────────────────────────────────────────────────────────┘

2. Type to filter (zoxide learns from usage)
3. Press Enter to create/switch to session
```

### Benefits
- Zoxide remembers frequently used directories
- Creates new sessions automatically for new directories
- Switches to existing sessions if they exist

---

## Session Persistence

### Scenario
You want your workspace to survive reboots, SSH disconnections, or accidental tmux kills.

### Automatic Behavior

Sessions are automatically:
- **Saved every 15 minutes** (via tmux-continuum)
- **Restored on tmux start** (via tmux-resurrect)

### Manual Save/Restore

```bash
# Manual save (if configured with prefix key)
Ctrl+b Ctrl+s    # Save now

# Manual restore
Ctrl+b Ctrl+r    # Restore sessions
```

### What Gets Saved

- Session names and layouts
- Window and pane configurations
- Working directories
- Running programs (vim, nvim, man, less, tail, git)
- Pane contents (for context)

### Recovery Scenario

```bash
# After system reboot or accidental tmux kill
tmux start-server

# All your sessions are automatically restored!
# - Same window layouts
# - Same working directories
# - Vim sessions restored (if using vim-sleuth or similar)
```

---

## Advanced Workflows

### Workflow 1: Full-Stack Development

```
Session: fullstack-app

Window 1 - Editor (Alt+1):
┌──────────────────┬──────────┐
│                  │          │
│    Frontend      │ Backend  │
│    (React)       │ (Node)   │
│                  │          │
│    Alt+v for     │          │
│    vertical      │          │
│    split         │          │
└──────────────────┴──────────┘

Window 2 - Services (Alt+2):
┌─────────────────────────────────┐
│  $ npm run dev:frontend         │
│  $ npm run dev:backend          │
│  $ docker-compose up            │
└─────────────────────────────────┘

Window 3 - Database (Alt+3):
┌─────────────────────────────────┐
│  $ psql -d myapp                │
│  or redis-cli, mongodb, etc.    │
└─────────────────────────────────┘
```

### Workflow 2: Code Review

```
1. Create review session
   tmux new -s review-pr-123

2. Split for side-by-side comparison
   Alt+s  # main-horizontal for top/bottom
   Alt+v  # main-vertical for left/right

3. Window organization
   Window 1: Old code (git checkout old-branch)
   Window 2: New code (git checkout pr-branch)
   Window 3: Test runner

4. Quick toggle between windows
   Alt+1 / Alt+2
```

### Workflow 3: Remote Development

```
1. SSH to remote with tmux config synced
   ssh user@remote

2. Attach or create session
   tmux attach -t project || tmux new -s project

3. If connection drops, session persists
   - Reconnect: ssh user@remote
   - Resume: tmux attach -t project
   - Everything is exactly as you left it

4. Clipboard works over SSH via OSC 52
   - Copy in tmux on remote
   - Paste locally in GUI apps
```

### Workflow 4: Pair Programming

```
1. Create shared session
   tmux new -s pair-session

2. Both users attach to same session
   User A: tmux attach -t pair-session
   User B: tmux attach -t pair-session

3. Synchronized viewing
   - Both see the same panes and windows
   - Either can type and control

4. Individual windows for notes
   - Each person can create private windows
   - Use Alt+Shift+number to move panes
```

### Workflow 5: Monitoring Dashboard

```
Window Layout:
┌─────────────────┬─────────────────┐
│  htop           │  kubectl logs   │
├─────────────────┼─────────────────┤
│  tail -f app.log│  watch npm test │
└─────────────────┴─────────────────┘

Setup:
1. Create panes with Alt+Enter
2. Switch layouts with Alt+s (horizontal) or Alt+v (vertical)
3. Resize with Alt+r then h/j/k/l

All monitoring in one view, switchable with Alt+h/j/k/l
```

---

## Tips & Tricks

### Quick Tips

1. **Zoom for Focus**: `Alt+z` to maximize current pane, `Alt+z` again to restore
2. **Quick Resize**: `Alt+r` → hold `l` to expand right pane continuously
3. **Kill Mistakes**: `Alt+Shift+q` asks for confirmation before killing
4. **Mouse Works**: Click panes, drag borders, scroll to enter copy mode
5. **Copy to Clipboard**: Select text in copy mode, `y` copies to system clipboard

### Performance Tips

1. **Limit History**: `set -g history-limit 50000` (adjust as needed)
2. **Status Interval**: Status bar updates every 15 seconds (not too frequent)
3. **Disable Preview**: If session switcher is slow, disable preview in config

### Customization Tips

1. **Add custom scripts**: Drop executable scripts in `~/.config/tmux/scripts/`
2. **Change default layout**: Edit `@tilish-default` in `.tmux.conf`
3. **Adjust colors**: Catppuccin theme can be customized via plugin settings
4. **Add keybindings**: Add custom `bind -n M-x` commands in `.tmux.conf`

---

## Common Issues & Solutions

### "Alt key doesn't work"

- Check terminal settings for Alt/Meta key configuration
- Some terminals need `Esc` prefix instead of `Alt`
- Try `Ctrl+b` prefix if Alt bindings fail completely

### "Clipboard not working over SSH"

- Ensure terminal supports OSC 52
- Check `set-clipboard on` and `allow-passthrough on`
- Test: In copy mode, select text and press `y`

### "Session not restoring"

- Verify tmux-resurrect and continuum plugins are installed
- Check `tmux show -g @continuum-restore` shows "on"
- Manual restore: `tmux-resurrect-restore` command

### "Layout looks wrong"

- Press `Alt+v` for main-vertical (default recommended)
- Press `Alt+s` for main-horizontal
- Use `Alt+r` resize mode to adjust

---

## Summary

tmux-i3-workflow provides a consistent, efficient workflow that matches i3wm:

1. **Familiar keybindings** - No relearning required
2. **Quick navigation** - `Alt+h/j/k/l` and `Alt+0-9`
3. **Flexible layouts** - Easy splitting and zooming
4. **Smart sessions** - One per project, persisted automatically
5. **Seamless clipboard** - Works locally and over SSH

Happy coding! 🚀
