# Specification: tmux-i3-workflow

## Metadata
- **Version**: 1.0.0
- **Status**: Realized
- **Author**: Spec-Write Agent
- **Created**: 2026-02-16
- **Last Updated**: 2026-02-16

## Overview

**tmux-i3-workflow** is a tmux configuration preset that brings i3wm-style workflow to terminal multiplexing. Designed for i3wm users, it provides familiar keybindings and workflow patterns, eliminating the learning curve for tmux while maintaining the efficiency of i3wm's window management philosophy.

### Core Principles
- **Muscle Memory Preservation**: Keybindings mirror i3wm's `$mod` + key pattern
- **No Prefix Mode**: Direct Alt-modified keys (like i3wm), no `Ctrl+b` prefix required
- **Session Isolation**: One session per project, keeping workspaces clean and focused
- **Minimalism**: Clean status bar, no visual clutter
- **Persistence**: Automatic session saving and restoration

### Target User
- i3wm users who want consistent keybindings across GUI and terminal
- Developers who work with multiple projects simultaneously
- Vim/Neovim users who need zero-conflict escape timing

## User Stories

> As an **i3wm user**, I want **Alt+number to switch windows** so that **my muscle memory works across both environments**.

> As a **developer**, I want **one session per project** so that **I can context-switch without losing my terminal layout**.

> As a **vim user**, I want **zero escape delay** so that **my editor responds instantly**.

> As a **multi-project worker**, I want **fuzzy session switching** so that **I can quickly jump between projects**.

> As a **terminal user**, I want **system clipboard integration** so that **I can copy/paste between terminal and GUI apps**.

> As an **i3wm user**, I want **h/j/k/l navigation** so that **I don't need to relearn navigation keys**.

> As a **remote worker**, I want **session persistence** so that **my workspace survives connection drops**.

## Requirements

### Functional Requirements

#### i3wm-Style Keybindings
- **FR-1**: `Alt+0-9` switches to window (workspace) 0-9
- **FR-2**: `Alt+Shift+0-9` moves current pane to window 0-9
- **FR-3**: `Alt+h/j/k/l` navigates focus between panes (vim-style)
- **FR-4**: `Alt+Shift+h/j/k/l` moves panes in corresponding direction
- **FR-5**: `Alt+Enter` creates a new pane with default layout
- **FR-6**: `Alt+s` toggles to horizontal split layout (main-horizontal)
- **FR-7**: `Alt+v` toggles to vertical split layout (main-vertical)
- **FR-8**: `Alt+z` toggles pane fullscreen (zoom)
- **FR-9**: `Alt+Shift+q` closes current pane with confirmation
- **FR-10**: `Alt+r` enters resize mode for pane resizing

#### Session Management
- **FR-11**: `Alt+d` opens fuzzy session switcher popup
- **FR-12**: Sessions are named based on project directory or custom name
- **FR-13**: New sessions can be created from zoxide directories
- **FR-14**: Session list shows all available sessions with preview
- **FR-15**: Sessions persist across tmux server restarts (via tmux-resurrect)
- **FR-16**: Sessions auto-save every 15 minutes (via tmux-continuum)

#### Window/Pane Management
- **FR-17**: Windows start at index 1 (not 0)
- **FR-18**: Panes start at index 1 (not 0)
- **FR-19**: Windows are renumbered when one is closed
- **FR-20**: Default layout is main-vertical (editor left, terminals right)
- **FR-21**: Panes can be swapped using `Alt+Shift+h/j/k/l`

#### Clipboard Integration
- **FR-22**: Selected text in copy mode is copied to system clipboard
- **FR-23**: System clipboard content can be pasted into tmux
- **FR-24**: OSC 52 escape sequences are supported for SSH sessions

#### Popup Tools
- **FR-25**: Session switcher opens as centered popup (not full-screen)
- **FR-26**: Zoxide directory picker opens as centered popup
- **FR-27**: Popups are dismissible with Escape key

### Non-functional Requirements

#### Performance
- **NFR-1**: Escape key response time is 0ms (no delay for vim users)
- **NFR-2**: Key binding response is immediate (< 50ms)
- **NFR-3**: Status bar refresh rate is reasonable (not resource-intensive)

#### Compatibility
- **NFR-4**: Works with tmux 3.2+
- **NFR-5**: Requires terminal with OSC 52 clipboard support (Kitty, Alacritty, iTerm2, Foot, etc.)
- **NFR-6**: OSC 52 clipboard works over SSH when terminal supports it

#### Usability
- **NFR-7**: Mouse support enabled for pane selection and resizing
- **NFR-8**: Status bar is minimal and informative
- **NFR-9**: Theme is visually consistent (Catppuccin)
- **NFR-10**: Installation is straightforward with single command

## Technical Design

### Plugin Architecture

| Plugin | Purpose | Source |
|--------|---------|--------|
| TPM | Plugin Manager | https://github.com/tmux-plugins/tpm |
| tmux-sensible | Sensible defaults | https://github.com/tmux-plugins/tmux-sensible |
| tmux-tilish | i3wm keybindings | https://github.com/jabirali/tmux-tilish |
| tmux-sessionx | Session management | https://github.com/omerxx/tmux-sessionx |
| catppuccin/tmux | Color theme | https://github.com/catppuccin/tmux |
| tmux-resurrect | Session save/restore | https://github.com/tmux-plugins/tmux-resurrect |
| tmux-continuum | Auto-save sessions | https://github.com/tmux-plugins/tmux-continuum |

### Keybinding Architecture

```
Modifier: Alt (M-)
No prefix mode - direct key binding

Navigation:
  Alt + h/j/k/l  -> Focus pane left/down/up/right
  Alt + 0-9      -> Select window 0-9

Pane Management:
  Alt + Enter    -> New pane (split based on current layout)
  Alt + s        -> Horizontal split (stacking)
  Alt + v        -> Vertical split (side by side)
  Alt + z        -> Toggle zoom (fullscreen)
  Alt + r        -> Enter resize mode

Pane Movement:
  Alt + Shift + h/j/k/l  -> Move pane in direction
  Alt + Shift + 0-9      -> Move pane to window

Session:
  Alt + d        -> Open session switcher popup
  Alt + Shift + q -> Kill current pane

Resize Mode (after Alt+r):
  h/j/k/l        -> Resize pane
  Escape         -> Exit resize mode
```

### Project Structure

```
tmux-i3-workflow/
├── .tmux.conf              # Main configuration file
├── README.md               # Installation & usage documentation
├── scripts/
│   ├── session-switcher.sh # Wrapper for tmux-sessionx
│   └── zoxide-jump.sh      # Zoxide integration helper
├── docs/
│   ├── keybindings.md      # Quick reference card
│   └── workflow.md         # Example workflows & tips
└── install.sh              # Optional installation script
```

### Configuration Highlights

#### Core Settings
```conf
# No escape delay (critical for vim)
set -s escape-time 0

# Index starts at 1
set -g base-index 1
setw -g pane-base-index 1

# Auto-renumber windows
set -g renumber-windows on

# Mouse support
set -g mouse on

# Vi mode for copy
setw -g mode-keys vi

# 256 colors + true color
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",*256col*:Tc"

# Extended keys for better modifier support
set -s extended-keys on
```

#### Clipboard (OSC 52)
```conf
# Enable OSC 52 clipboard (works in Kitty, Alacritty, iTerm2, etc.)
set -g set-clipboard on

# SSH passthrough for OSC 52
set -g allow-passthrough on

# Vi-mode copy using OSC 52
bind -T copy-mode-vi y send -X copy-pipe-and-cancel ""
```

> **Note**: OSC 52 is a terminal escape sequence that enables clipboard access without external tools. The terminal emulator handles clipboard operations natively.

#### Layout Strategy
- Default layout: `main-vertical` (60% left for editor, 40% right for terminals)
- Alternative: `main-horizontal` (60% top, 40% bottom)
- Full toggle with `Alt+z`

### Status Bar Design

```
[Session Name] | [Window List: 1:editor 2:term 3:git] | [Time]
```

- Left: Session name (project name)
- Center: Window list with indicators
- Right: Time and optional system info
- Colors: Catppuccin Mocha flavor

### Session Persistence Strategy

| Feature | Configuration |
|---------|---------------|
| Auto-save interval | 15 minutes |
| Restore on start | Yes |
| Save programs | vim, nvim, emacs, man, less, tail, git |
| Save pane contents | Yes (for context) |

## Test Steps

### Prerequisites
```bash
# Verify tmux version
tmux -V  # Should be 3.2+

# Verify required tools
which fzf      # For sessionx
which zoxide   # For directory jumping

# Verify terminal OSC 52 support (optional)
# In Kitty: should work by default
# In Alacritty: add to alacritty.yml: "terminal.osc52: CopyPaste"
```

### Installation Test

```bash
# Clone repository
git clone <repo-url> ~/.config/tmux-i3-workflow

# Create symlink or copy config
ln -s ~/.config/tmux-i3-workflow/.tmux.conf ~/.tmux.conf

# Install TPM if not exists
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Start tmux and install plugins
tmux new -s test
# Press Alt+I (or prefix + I) to install plugins
```

### Functional Tests

#### Test 1: i3wm Keybindings
```bash
# Start new session
tmux new -s keybind-test

# Test window switching (Alt+1, Alt+2, etc.)
# Create multiple windows first: Alt+Enter, then Alt+c (new window)

# Test pane navigation
# Split pane: Alt+v
# Navigate: Alt+h, Alt+l

# Test pane movement
# Move pane: Alt+Shift+h/j/k/l

# Test fullscreen toggle
# Fullscreen: Alt+z
# Exit fullscreen: Alt+z

# Cleanup
tmux kill-session -t keybind-test
```

#### Test 2: Session Management
```bash
# Test session switcher
tmux new -s project-a
tmux new -s project-b

# In tmux, press Alt+d
# Should see fzf popup with sessions list
# Select to switch

# Test session persistence
tmux kill-server
tmux start-server
# Sessions should be restored automatically
```

#### Test 3: Clipboard Integration
```bash
# Enter copy mode: Alt+[
# Select text with v (visual) and y (yank)
# Text should be in system clipboard
# Test paste in another application

# Test paste into tmux
# Copy text from GUI app
# In tmux: Alt+v (or appropriate paste binding)
```

#### Test 4: Layout Management
```bash
tmux new -s layout-test

# Test main-vertical (default)
# Should have main pane on left

# Test main-horizontal
# Press Alt+s
# Should have main pane on top

# Test zoom
# Press Alt+z
# Current pane should be fullscreen

# Cleanup
tmux kill-session -t layout-test
```

#### Test 5: Zoxide Integration
```bash
# Add some directories to zoxide
z add ~/projects/project-a
z add ~/projects/project-b

# In tmux, trigger zoxide popup
# Should see fzf list of directories
# Select to create/jump to session
```

#### Test 6: Resize Mode
```bash
tmux new -s resize-test

# Press Alt+r to enter resize mode
# Press h/j/k/l to resize pane
# Press Escape to exit resize mode

# Cleanup
tmux kill-session -t resize-test
```

#### Test 7: Kill Pane
```bash
tmux new -s kill-test

# Split pane: Alt+v
# Press Alt+Shift+q to kill pane
# Pane should close

# Cleanup
tmux kill-session -t kill-test
```

### Edge Case Tests

#### Test 8: Escape Timing
```bash
# Open vim in tmux
vim test.txt
# Press Escape followed immediately by other keys
# Should respond instantly without delay

# Test in insert mode
# Type some text, press Esc, then j
# Should exit insert and move down immediately
```

#### Test 9: SSH Session
```bash
# SSH to remote machine with tmux config synced
ssh user@remote

# Test clipboard over SSH
# Select text in copy mode
# Should sync to local clipboard via OSC 52
```

#### Test 10: Multi-Window Workflow
```bash
tmux new -s multi-test

# Create 3 windows
# Window 1: editor
# Window 2: terminal
# Window 3: git

# Test Alt+1, Alt+2, Alt+3 switching
# Test Alt+Shift+2 to move pane to window 2

# Kill window 2
# Verify windows renumber (3 becomes 2)

tmux kill-session -t multi-test
```

### Verification Commands

```bash
# Verify plugins installed
ls ~/.tmux/plugins/
# Should see: tpm, tmux-sensible, tmux-tilish, tmux-sessionx, etc.

# Verify keybindings
tmux list-keys | grep "M-"
# Should show Alt-based bindings

# Verify settings
tmux show -g | grep escape-time
# Should show: set -gs escape-time 0
```

## Acceptance Criteria

### AC-1: i3wm Navigation Compatibility
```gherkin
Scenario: User navigates panes with i3wm-style keys
  Given I have multiple panes open
  When I press Alt+h
  Then focus moves to the pane on the left
  When I press Alt+l
  Then focus moves to the pane on the right
  When I press Alt+j
  Then focus moves to the pane below
  When I press Alt+k
  Then focus moves to the pane above
```

### AC-2: Window Switching by Number
```gherkin
Scenario: User switches windows with Alt+number
  Given I have windows 1, 2, and 3 open
  When I press Alt+2
  Then window 2 becomes active
  When I press Alt+1
  Then window 1 becomes active
```

### AC-3: Pane Movement
```gherkin
Scenario: User moves panes with Alt+Shift+hjkl
  Given I have two panes side by side
  When I press Alt+Shift+l
  Then the current pane moves to the right
  When I press Alt+Shift+h
  Then the current pane moves to the left
```

### AC-4: Layout Toggle
```gherkin
Scenario: User toggles between layouts
  Given I am in main-vertical layout
  When I press Alt+s
  Then layout changes to main-horizontal
  When I press Alt+v
  Then layout changes to main-vertical
```

### AC-5: Fullscreen Zoom
```gherkin
Scenario: User zooms pane to fullscreen
  Given I have multiple panes visible
  When I press Alt+z
  Then current pane fills the entire window
  And other panes are hidden
  When I press Alt+z again
  Then previous layout is restored
```

### AC-6: Session Switcher
```gherkin
Scenario: User switches sessions via popup
  Given I have multiple sessions: "project-a", "project-b"
  And I am currently in "project-a"
  When I press Alt+d
  Then a centered popup appears
  And shows list of all sessions
  When I select "project-b"
  Then I am switched to "project-b" session
```

### AC-7: Clipboard Integration
```gherkin
Scenario: User copies text to system clipboard
  Given I am in copy mode
  When I select text with visual mode
  And I press y
  Then the selected text is in system clipboard
  And I can paste it in other applications
```

### AC-8: Zero Escape Delay
```gherkin
Scenario: Vim user experiences no escape delay
  Given I am running vim inside tmux
  And I am in insert mode
  When I press Escape followed immediately by j
  Then vim exits insert mode
  And cursor moves down
  And there is no perceptible delay
```

### AC-9: Session Persistence
```gherkin
Scenario: Sessions persist after restart
  Given I have a session "my-project" with 3 windows
  And tmux-resurrect and continuum are configured
  When I restart tmux server
  Then session "my-project" is restored
  And all 3 windows are present
  And pane layouts are preserved
```

### AC-10: Mouse Support
```gherkin
Scenario: User can interact with mouse
  Given mouse support is enabled
  When I click on a pane
  Then that pane becomes active
  When I drag a pane border
  Then the pane resizes
  When I scroll the mouse wheel
  Then copy mode is entered for scrolling
```

### AC-11: Window Renumbering
```gherkin
Scenario: Windows renumber after deletion
  Given I have windows 1, 2, and 3
  When I close window 2
  Then window 3 becomes window 2
  And I can switch to it with Alt+2
```

### AC-12: Zoxide Integration
```gherkin
Scenario: User jumps to project via zoxide
  Given I have directories in zoxide database
  When I trigger the zoxide popup
  Then I see a list of recently used directories
  When I select a directory
  Then a new session is created (or existing one is attached)
  And the working directory is set correctly
```

### AC-13: Catppuccin Theme
```gherkin
Scenario: Status bar uses Catppuccin colors
  Given catppuccin plugin is installed and configured
  When I view the status bar
  Then colors match Catppuccin Mocha palette
  And the design is clean and minimal
```

### AC-14: Plugin Installation
```gherkin
Scenario: User installs plugins via TPM
  Given TPM is installed
  And .tmux.conf lists all required plugins
  When I press Alt+I (or prefix + I)
  Then all plugins are downloaded and installed
  And tmux source is reloaded
```

### AC-15: Index Starts at 1
```gherkin
Scenario: Windows and panes start at index 1
  Given I start a new tmux session
  When I create the first window
  Then its index is 1 (not 0)
  When I create the first pane
  Then its index is 1 (not 0)
```

## Dependencies

### Required
- **tmux** >= 3.2
- **TPM** (Tmux Plugin Manager)
- **fzf** (for fuzzy finding)
- **Terminal with OSC 52 support** (Kitty, Alacritty, iTerm2, Foot, etc.)

### Recommended
- **zoxide** (for smart directory jumping)

### Terminal Compatibility

> **Important**: Terminal must support OSC 52 clipboard sequences for copy/paste functionality.

### OSC 52 Clipboard Support

| Terminal      | OSC 52 Support | Notes                    |
| ------------- | -------------- | ------------------------ |
| Kitty         | ✅ Yes         | User's terminal          |
| Alacritty     | ✅ Yes         | Requires config          |
| iTerm2        | ✅ Yes         | Default enabled          |
| Foot          | ✅ Yes         | Wayland native           |
| WezTerm       | ⚠️ Partial     | Copy works, paste limited |
| Ghostty       | ✅ Yes         | Default enabled          |
| Hyper         | ❌ No          | Not recommended          |
| Konsole       | ⚠️ Partial     | May need config          |

## Out of Scope

The following are explicitly out of scope for v1.0.0:

- **Custom theme builder** - Only Catppuccin is supported
- **Multi-user session sharing** - Single user focus
- **Complex status bar widgets** - Minimal status bar only
- **Auto-install script for dependencies** - Manual dependency installation
- **Windows/PowerShell support** - Unix-like systems only
- **Non-Alt modifier options** - Alt is the only modifier

## Change Log

| Date       | Version | Description       | Author           |
|------------|---------|-------------------|------------------|
| 2026-02-16 | 1.0.0   | Initial draft     | Spec-Write Agent |
| 2026-02-16 | 1.0.0   | Revised based on feasibility study: OSC 52 clipboard, test steps, terminal notes | Spec-Write Agent |
| 2026-02-16 | 1.0.0   | Activated for implementation | Spec-Write Agent |
| 2026-02-16 | 1.0.0   | Marked as Realized - implementation complete | Spec-Write Agent |
