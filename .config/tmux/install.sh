#!/usr/bin/env bash
# ============================================================================
# install.sh - Installation script for tmux-i3-workflow
# ============================================================================
# This script checks prerequisites and sets up the tmux configuration.
# ============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              tmux-i3-workflow Installer                       ║"
echo "║           i3wm-style workflow for tmux                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================================
# Helper Functions
# ============================================================================

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

# ============================================================================
# Prerequisite Checks
# ============================================================================

echo ""
echo "Checking prerequisites..."
echo "-------------------------"

# Check tmux version
check_tmux() {
    if ! command -v tmux &> /dev/null; then
        print_error "tmux is not installed"
        return 1
    fi
    
    TMUX_VERSION=$(tmux -V | grep -oP '\d+\.\d+' | head -1)
    REQUIRED_VERSION="3.2"
    
    if [[ "$(printf '%s\n' "$REQUIRED_VERSION" "$TMUX_VERSION" | sort -V | head -1)" != "$REQUIRED_VERSION" ]]; then
        print_error "tmux version $TMUX_VERSION is too old (requires >= $REQUIRED_VERSION)"
        return 1
    fi
    
    print_success "tmux $TMUX_VERSION (>= 3.2)"
    return 0
}

# Check fzf
check_fzf() {
    if command -v fzf &> /dev/null; then
        print_success "fzf installed"
        return 0
    else
        print_warning "fzf not installed (required for session switcher)"
        print_info "  Install from: https://github.com/junegunn/fzf"
        return 1
    fi
}

# Check zoxide
check_zoxide() {
    if command -v zoxide &> /dev/null; then
        print_success "zoxide installed"
        return 0
    else
        print_warning "zoxide not installed (recommended for directory jumping)"
        print_info "  Install from: https://github.com/ajeetdsouza/zoxide"
        return 0  # Not required, just recommended
    fi
}

# Check terminal OSC 52 support
check_terminal() {
    print_info "Terminal: ${TERM:-unknown}"
    print_info "Note: OSC 52 clipboard requires compatible terminal (Kitty, Alacritty, iTerm2, Foot)"
    return 0
}

# Run all checks
ERRORS=0
check_tmux || ((ERRORS++))
check_fzf || ((ERRORS++))
check_zoxide
check_terminal

if [[ $ERRORS -gt 0 ]]; then
    echo ""
    print_error "Missing required dependencies. Please install them and try again."
    exit 1
fi

# ============================================================================
# Installation Steps
# ============================================================================

echo ""
echo "Installing tmux-i3-workflow..."
echo "------------------------------"

# Create necessary directories
print_info "Creating directories..."
mkdir -p "$HOME/.tmux/plugins"
mkdir -p "$HOME/.config/tmux/scripts"

# Install TPM if not present
TPM_PATH="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_PATH" ]]; then
    print_info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
    $TPM_PATH/scripts/install_plugins.sh
    print_success "TPM installed"
else
    print_success "TPM already installed"
fi

# Create symlink for .tmux.conf
TMUX_CONF="$HOME/.tmux.conf"
if [[ -L "$TMUX_CONF" ]]; then
    print_info "Removing existing symlink..."
    rm "$TMUX_CONF"
elif [[ -f "$TMUX_CONF" ]]; then
    print_info "Backing up existing .tmux.conf..."
    mv "$TMUX_CONF" "$TMUX_CONF.backup.$(date +%Y%m%d%H%M%S)"
fi

print_info "Creating symlink for .tmux.conf..."
ln -s "$SCRIPT_DIR/.tmux.conf" "$TMUX_CONF"
print_success ".tmux.conf symlinked"

# Copy scripts to ~/.config/tmux/scripts/
# print_info "Installing helper scripts..."
# cp "$SCRIPT_DIR/scripts/zoxide-jump.sh" "$HOME/.config/tmux/scripts/"
# cp "$SCRIPT_DIR/scripts/session-switcher.sh" "$HOME/.config/tmux/scripts/"
# chmod +x "$HOME/.config/tmux/scripts/"*.sh
# print_success "Scripts installed to ~/.config/tmux/scripts/"

# ============================================================================
# Post-installation Instructions
# ============================================================================

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                 Installation Complete!                        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo "  1. Start tmux:"
echo "     ${BLUE}tmux new -s my-project${NC}"
echo ""
echo "  2. Install plugins (inside tmux):"
echo "     ${BLUE}Press Alt+I${NC} (or Ctrl+b then I if Alt+I doesn't work)"
echo ""
echo "  3. Verify installation:"
echo "     ${BLUE}tmux list-keys | grep 'M-'${NC}"
echo ""
echo "Keybindings:"
echo "  ${YELLOW}Alt+h/j/k/l${NC}    - Navigate panes (vim-style)"
echo "  ${YELLOW}Alt+0-9${NC}        - Switch windows"
echo "  ${YELLOW}Alt+Enter${NC}      - Create new pane"
echo "  ${YELLOW}Alt+s/v${NC}        - Toggle layout"
echo "  ${YELLOW}Alt+z${NC}          - Zoom pane"
echo "  ${YELLOW}Alt+f${NC}          - Session switcher"
echo "  ${YELLOW}Alt+o${NC}          - Zoxide directory picker"
echo ""
echo "For more information, see:"
echo "  ${BLUE}README.md${NC}"
echo "  ${BLUE}docs/keybindings.md${NC}"
echo "  ${BLUE}docs/workflow.md${NC}"
echo ""
