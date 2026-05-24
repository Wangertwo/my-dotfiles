#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_suffix="backup-$(date +%Y%m%d%H%M%S)"

info() {
    printf '[INFO] %s\n' "$*"
}

warn() {
    printf '[WARN] %s\n' "$*" >&2
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

sudo_cmd() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        require_command sudo
        sudo "$@"
    fi
}

ensure_ubuntu() {
    if [ ! -r /etc/os-release ]; then
        printf 'Cannot detect OS: /etc/os-release is missing. This installer supports Ubuntu.\n' >&2
        exit 1
    fi

    . /etc/os-release
    case "${ID:-}" in
        ubuntu) ;;
        *)
            printf 'Unsupported OS: %s. This installer supports Ubuntu.\n' "${PRETTY_NAME:-unknown}" >&2
            exit 1
            ;;
    esac
}

install_packages() {
    local packages=(
        bat
        build-essential
        ca-certificates
        curl
        fd-find
        fish
        fzf
        git
        neovim
        nodejs
        npm
        python3
        python3-pip
        python3-venv
        ripgrep
        tmux
        unzip
        zoxide
    )
    local missing=()

    for package in "${packages[@]}"; do
        if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'install ok installed'; then
            missing+=("$package")
        fi
    done

    if [ "${#missing[@]}" -gt 0 ]; then
        info "Installing Ubuntu packages: ${missing[*]}"
        sudo_cmd apt-get update
        sudo_cmd apt-get install -y "${missing[@]}"
    fi
}

ensure_command_aliases() {
    mkdir -p "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"

    if ! command_exists bat && command_exists batcat; then
        ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
    fi

    if ! command_exists fd && command_exists fdfind; then
        ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
    fi
}

require_command() {
    if ! command_exists "$1"; then
        printf 'Required command is missing after installation: %s\n' "$1" >&2
        exit 1
    fi
}

backup_path() {
    local target="$1"

    if [ -L "$target" ]; then
        rm "$target"
    elif [ -e "$target" ]; then
        mv "$target" "$target.$backup_suffix"
        info "Backed up $target to $target.$backup_suffix"
    fi
}

link_config() {
    local name="$1"
    local source="$repo_dir/.config/$name"
    local target="$HOME/.config/$name"

    if [ ! -d "$source" ]; then
        printf 'Missing repository config directory: %s\n' "$source" >&2
        exit 1
    fi

    mkdir -p "$HOME/.config"
    backup_path "$target"
    ln -s "$source" "$target"
    info "Linked $target -> $source"
}

link_configs() {
    link_config fish
    link_config nvim
    link_config tmux

    if [ -f "$repo_dir/.config/tmux/.tmux.conf" ]; then
        backup_path "$HOME/.tmux.conf"
        ln -s "$repo_dir/.config/tmux/.tmux.conf" "$HOME/.tmux.conf"
        info "Linked $HOME/.tmux.conf -> $repo_dir/.config/tmux/.tmux.conf"
    fi
}

setup_fish() {
    require_command fish
    fish "$HOME/.config/fish/setup.fish"

    if command_exists chsh && [ "${SHELL:-}" != "$(command -v fish)" ]; then
        if sudo_cmd chsh -s "$(command -v fish)" "$USER"; then
            info "Changed default shell for $USER to fish"
        else
            warn "Could not change default shell automatically; run: sudo chsh -s $(command -v fish) $USER"
        fi
    fi
}

setup_neovim() {
    require_command nvim
    nvim --headless '+Lazy! sync' +qa
}

main() {
    ensure_ubuntu
    install_packages
    ensure_command_aliases

    require_command git
    require_command tmux
    require_command fzf
    require_command rg
    require_command fd
    require_command bat
    require_command zoxide

    link_configs
    setup_fish
    setup_neovim

    info "Dotfiles installed from $repo_dir"
    info "Open a new terminal, or run: exec fish"
}

main "$@"
