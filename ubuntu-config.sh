#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME="$(basename "$0")"
LOG_DIR="${LOG_DIR:-$HOME/ubuntu-config-logs}"
LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"
STAGE="bootstrap"
FAILED_COMMAND=""

MY_DOTFILES_REPO="${MY_DOTFILES_REPO:-https://github.com/Wangertwo/my-dotfiles.git}"
CLAUDE_DOTFILES_REPO="${CLAUDE_DOTFILES_REPO:-https://github.com/Wangertwo/dotfiles-claude.git}"
MY_DOTFILES_DIR="${MY_DOTFILES_DIR:-$HOME/my-dotfiles}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
NVIM_VERSION="${NVIM_VERSION:-v0.12.2}"
NVIM_INSTALL_DIR="${NVIM_INSTALL_DIR:-/opt/nvim-linux-x86_64}"
INSTALL_CODEX="${INSTALL_CODEX:-1}"
RUN_CLAUDE_SETUP="${RUN_CLAUDE_SETUP:-1}"
RUN_NVIM_SYNC="${RUN_NVIM_SYNC:-1}"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

log() {
    printf '[%s] [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$STAGE" "$*"
}

section() {
    STAGE="$1"
    log "=== $1 ==="
}

run() {
    FAILED_COMMAND="$*"
    log "RUN: $*"
    "$@"
    FAILED_COMMAND=""
}

on_error() {
    local exit_code=$?
    local line_no=${BASH_LINENO[0]:-${LINENO}}
    printf '\nFAILED\n'
    printf '  stage: %s\n' "$STAGE"
    printf '  line: %s\n' "$line_no"
    printf '  exit_code: %s\n' "$exit_code"
    printf '  command: %s\n' "${FAILED_COMMAND:-unknown}"
    printf '  log: %s\n' "$LOG_FILE"
    printf '\nLast 40 log lines:\n'
    tail -n 40 "$LOG_FILE" || true
    exit "$exit_code"
}
trap on_error ERR

usage() {
    cat <<'USAGE'
Usage: ./ubuntu-config.sh [--verify-only] [--no-codex] [--no-claude-setup] [--no-nvim-sync]

Environment overrides:
  MY_DOTFILES_REPO        default: https://github.com/Wangertwo/my-dotfiles.git
  CLAUDE_DOTFILES_REPO    default: https://github.com/Wangertwo/dotfiles-claude.git
  MY_DOTFILES_DIR         default: ~/my-dotfiles
  CLAUDE_DIR              default: ~/.claude
  NVIM_VERSION            default: v0.12.2
  NVIM_INSTALL_DIR        default: /opt/nvim-linux-x86_64
  LOG_DIR                 default: ~/ubuntu-config-logs

The script logs every stage and prints stage/line/command/log path on failure.
USAGE
}

VERIFY_ONLY=0
while [ "$#" -gt 0 ]; do
    case "$1" in
        --verify-only) VERIFY_ONLY=1 ;;
        --no-codex) INSTALL_CODEX=0 ;;
        --no-claude-setup) RUN_CLAUDE_SETUP=0 ;;
        --no-nvim-sync) RUN_NVIM_SYNC=0 ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown argument: %s\n' "$1" >&2; usage; exit 2 ;;
    esac
    shift
done

require_command() {
    command -v "$1" >/dev/null 2>&1
}

sudo_run() {
    FAILED_COMMAND="sudo $*"
    if [ "$(id -u)" -eq 0 ]; then
        log "RUN: $*"
        "$@"
    else
        log "RUN: sudo $*"
        sudo "$@"
    fi
    FAILED_COMMAND=""
}

sudo_capture() {
    local output_file="$1"
    shift
    if [ "$(id -u)" -eq 0 ]; then
        "$@" > "$output_file" 2>&1
    else
        sudo "$@" > "$output_file" 2>&1
    fi
}

ensure_ubuntu() {
    section "check-os"
    if [ ! -r /etc/os-release ]; then
        printf 'Cannot read /etc/os-release. This script supports Ubuntu only.\n' >&2
        exit 1
    fi
    . /etc/os-release
    if [ "${ID:-}" != "ubuntu" ]; then
        printf 'Unsupported OS: %s. This script supports Ubuntu only.\n' "${PRETTY_NAME:-unknown}" >&2
        exit 1
    fi
    log "Detected ${PRETTY_NAME:-Ubuntu}"
}

apt_get_update_with_recovery() {
    section "apt-update"
    local attempt
    local output_file
    output_file="$(mktemp)"

    for attempt in 1 2 3 4 5; do
        if [ "$(id -u)" -eq 0 ]; then
            FAILED_COMMAND="apt-get update"
            log "RUN: apt-get update (attempt $attempt)"
        else
            FAILED_COMMAND="sudo apt-get update"
            log "RUN: sudo apt-get update (attempt $attempt)"
        fi
        if sudo_capture "$output_file" apt-get update; then
            cat "$output_file"
            FAILED_COMMAND=""
            rm -f "$output_file"
            return
        fi
        cat "$output_file"

        if ! grep -q "does not have a Release file" "$output_file"; then
            printf 'apt-get update failed for a reason this script will not auto-repair.\n' >&2
            printf 'Check log: %s\n' "$LOG_FILE" >&2
            return 1
        fi

        local repo_spec
        repo_spec="$(grep "does not have a Release file" "$output_file" | grep -o "'[^']*'" | head -n 1 | tr -d "'")"
        if [ -z "$repo_spec" ]; then
            printf 'Could not parse the failing apt repository from apt-get output.\n' >&2
            return 1
        fi

        local repo_url
        repo_url="${repo_spec%% *}"
        log "Detected unsupported apt source: $repo_url"

        local disabled_any=0
        local disabled_dir="/etc/apt/disabled-sources-by-ubuntu-config"
        sudo_run mkdir -p "$disabled_dir"

        local source_file
        while IFS= read -r source_file; do
            [ -n "$source_file" ] || continue
            if [[ "$source_file" == /etc/apt/sources.list.d/* ]]; then
                sudo_run mv "$source_file" "$disabled_dir/$(basename "$source_file").disabled-$(date +%Y%m%d%H%M%S)"
                disabled_any=1
            else
                printf 'Unsupported apt source is in %s; refusing to edit the main apt source file automatically.\n' "$source_file" >&2
                printf 'Disable the line for %s manually, then rerun this script.\n' "$repo_url" >&2
                return 1
            fi
        done < <(grep -R -l -F "$repo_url" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null || true)

        if [ "$disabled_any" != "1" ]; then
            printf 'Could not find a source file containing %s.\n' "$repo_url" >&2
            return 1
        fi

        log "Disabled unsupported apt source and will retry apt-get update"
    done

    printf 'apt-get update still failed after disabling unsupported sources.\n' >&2
    return 1
}

install_apt_packages() {
    section "apt-packages"
    apt_get_update_with_recovery
    sudo_run apt-get install -y \
        git sudo curl ca-certificates build-essential unzip xz-utils \
        fish tmux fzf ripgrep fd-find bat zoxide \
        nodejs npm python3 python3-pip python3-venv jq rsync less
}

ensure_ubuntu_command_aliases() {
    section "ubuntu-command-aliases"
    run mkdir -p "$HOME/.local/bin"
    if ! require_command fd && require_command fdfind; then
        run ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
    fi
    if ! require_command bat && require_command batcat; then
        run ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
    fi
}

ensure_path_for_session() {
    export PATH="$HOME/.local/bin:$PATH"
}

install_uv() {
    section "uv"
    if require_command uv; then
        log "uv already installed: $(uv --version)"
        return
    fi
    run sh -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
    ensure_path_for_session
    run uv --version
}

install_claude_code() {
    section "claude-code"
    if require_command claude; then
        log "claude already installed: $(claude --version)"
        return
    fi
    run sh -c 'curl -fsSL https://claude.ai/install.sh | bash'
    ensure_path_for_session
    run claude --version
}

install_neovim() {
    section "neovim"
    local nvim_version_label="${NVIM_VERSION#v}"
    if require_command nvim; then
        if nvim --version | grep -q "NVIM v${nvim_version_label}"; then
            log "nvim ${NVIM_VERSION} already available: $(command -v nvim)"
            return
        fi
        log "Existing nvim is not ${NVIM_VERSION}; installing target build under $NVIM_INSTALL_DIR"
    fi

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    FAILED_COMMAND="download neovim ${NVIM_VERSION}"
    curl -fL "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz" -o "$tmp_dir/nvim-linux-x86_64.tar.gz"
    FAILED_COMMAND="extract neovim ${NVIM_VERSION}"
    tar -xzf "$tmp_dir/nvim-linux-x86_64.tar.gz" -C "$tmp_dir"
    sudo_run rm -rf "$NVIM_INSTALL_DIR"
    sudo_run mv "$tmp_dir/nvim-linux-x86_64" "$NVIM_INSTALL_DIR"
    run mkdir -p "$HOME/.local/bin"
    run ln -sf "$NVIM_INSTALL_DIR/bin/nvim" "$HOME/.local/bin/nvim"
    ensure_path_for_session
    run nvim --version
}

clone_or_update_repo() {
    local repo="$1"
    local dir="$2"
    local label="$3"
    section "repo-$label"
    if [ -d "$dir/.git" ]; then
        log "Updating existing $label checkout at $dir"
        run git -C "$dir" remote set-url origin "$repo"
        run git -C "$dir" fetch --prune origin
        run git -C "$dir" pull --ff-only
    elif [ -e "$dir" ]; then
        local backup="$dir.backup-$(date +%Y%m%d-%H%M%S)"
        log "$dir exists and is not a git checkout; moving to $backup"
        run mv "$dir" "$backup"
        run git clone "$repo" "$dir"
    else
        run git clone "$repo" "$dir"
    fi
}

clone_tmux_plugin() {
    local plugin="$1"
    local plugin_dir="$HOME/.tmux/plugins/${plugin##*/}"

    if [ -d "$plugin_dir/.git" ]; then
        run git -C "$plugin_dir" pull --ff-only
    else
        run git clone "https://github.com/${plugin}.git" "$plugin_dir"
    fi
}

setup_tmux_plugins() {
    section "tmux-plugin-setup"
    local tmux_conf="$HOME/.config/tmux/.tmux.conf"
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [ ! -f "$tmux_conf" ]; then
        log "tmux config not found at $tmux_conf; skip tmux plugin setup"
        return
    fi

    run mkdir -p "$HOME/.tmux/plugins"
    clone_tmux_plugin "tmux-plugins/tpm"

    run tmux start-server
    run tmux source-file "$tmux_conf"

    if [ -x "$tpm_dir/bin/install_plugins" ]; then
        run "$tpm_dir/bin/install_plugins"
    elif [ -x "$tpm_dir/scripts/install_plugins.sh" ]; then
        run "$tpm_dir/scripts/install_plugins.sh"
    else
        printf 'TPM install script not found under %s\n' "$tpm_dir" >&2
        return 1
    fi

    clone_tmux_plugin "tmux-plugins/tmux-battery"
    clone_tmux_plugin "tmux-plugins/tmux-cpu"
    clone_tmux_plugin "tmux-plugins/tmux-sensible"
    clone_tmux_plugin "jabirali/tmux-tilish"
    clone_tmux_plugin "omerxx/tmux-sessionx"
    clone_tmux_plugin "catppuccin/tmux"
    clone_tmux_plugin "tmux-plugins/tmux-resurrect"
    clone_tmux_plugin "tmux-plugins/tmux-continuum"
    clone_tmux_plugin "NHDaly/tmux-better-mouse-mode"

    if ! grep -q 'catppuccin.tmux' "$tmux_conf"; then
        local marker='set -g @catppuccin_window_status_style "rounded"'
        local insert="if-shell 'test -f ~/.tmux/plugins/tmux/catppuccin.tmux' \\\n    'run ~/.tmux/plugins/tmux/catppuccin.tmux'"
        python3 -c 'from pathlib import Path; import sys; path=Path(sys.argv[1]); marker=sys.argv[2]; insert=sys.argv[3]; text=path.read_text(); path.write_text(text.replace(marker, marker + "\n\n" + insert, 1) if insert not in text else text)' "$tmux_conf" "$marker" "$insert"
    fi

    run tmux source-file "$tmux_conf"
    run tmux run-shell ~/.tmux/plugins/tmux/catppuccin.tmux
    log "tmux status-style: $(tmux show -gqv status-style)"
    log "tmux status-right: $(tmux show -gqv status-right)"
    log "tmux catppuccin flavor: $(tmux show -gqv @catppuccin_flavor)"
    log "Reloaded tmux config after plugin installation"
}

install_my_dotfiles() {
    clone_or_update_repo "$MY_DOTFILES_REPO" "$MY_DOTFILES_DIR" "my-dotfiles"
    section "my-dotfiles-install"
    run bash "$MY_DOTFILES_DIR/install.sh"
    setup_tmux_plugins
}

install_claude_plugins() {
    section "claude-plugin-install"
    local settings="$CLAUDE_DIR/settings.json"
    local installed_json="$CLAUDE_DIR/plugins/installed_plugins.json"
    local installed=""
    local plugin

    if [ ! -f "$settings" ]; then
        log "Claude settings.json not found; skip plugin install"
        return
    fi

    if [ -f "$installed_json" ]; then
        installed="$(jq -r '.plugins | keys[]' "$installed_json" 2>/dev/null || true)"
    fi

    while IFS= read -r plugin; do
        [ -n "$plugin" ] || continue
        if grep -qxF "$plugin" <<< "$installed"; then
            log "Claude plugin already installed: $plugin"
            continue
        fi
        log "RUN: claude plugin install $plugin"
        if ! claude plugin install "$plugin"; then
            log "Claude plugin install failed, continuing: $plugin"
        fi
    done < <(jq -r '.enabledPlugins // {} | to_entries[] | select(.value == true) | .key' "$settings")
}

install_claude_dotfiles() {
    clone_or_update_repo "$CLAUDE_DOTFILES_REPO" "$CLAUDE_DIR" "dotfiles-claude"

    section "claude-dotfiles-remote-check"
    local origin
    origin="$(git -C "$CLAUDE_DIR" remote get-url origin)"
    if [ "$origin" != "$CLAUDE_DOTFILES_REPO" ]; then
        printf 'Unexpected ~/.claude origin: %s\nExpected: %s\n' "$origin" "$CLAUDE_DOTFILES_REPO" >&2
        exit 1
    fi
    log "Claude dotfiles origin OK: $origin"

    if [ "$RUN_CLAUDE_SETUP" = "1" ]; then
        section "claude-dotfiles-setup"
        if grep -q "REPO=\"$CLAUDE_DOTFILES_REPO\"" "$CLAUDE_DIR/setup.sh"; then
            run bash "$CLAUDE_DIR/setup.sh"
        else
            log "setup.sh manages a different repository; installing enabled plugins directly"
            install_claude_plugins
        fi
    fi

    section "claude-fish-integration"
    if [ -f "$HOME/.config/fish/config.fish" ]; then
        if ! grep -qxF 'source ~/.claude/integration.fish' "$HOME/.config/fish/config.fish"; then
            printf '\nsource ~/.claude/integration.fish\n' >> "$HOME/.config/fish/config.fish"
            log "Appended Claude fish integration"
        else
            log "Claude fish integration already present"
        fi
        if ! grep -qxF 'source ~/.claude/integration-providers.fish' "$HOME/.config/fish/config.fish"; then
            printf '\nsource ~/.claude/integration-providers.fish\n' >> "$HOME/.config/fish/config.fish"
            log "Appended Claude provider fish integration"
        else
            log "Claude provider fish integration already present"
        fi
    else
        log "fish config not found; skip shell integration append"
    fi
}

install_codex() {
    section "codex"
    if [ "$INSTALL_CODEX" != "1" ]; then
        log "Skipped codex install by flag"
        return
    fi
    if require_command codex; then
        log "codex already installed: $(codex --version)"
        return
    fi
    sudo_run npm install -g @openai/codex
    run codex --version
    log "Run 'codex login' manually after this script if you want Codex integration."
}

sync_neovim_plugins() {
    section "neovim-plugin-sync"
    if [ "$RUN_NVIM_SYNC" != "1" ]; then
        log "Skipped Neovim plugin sync by flag"
        return
    fi
    run nvim --headless '+Lazy! sync' +qa
}

verify() {
    section "verify"
    run bash -lc 'set -e; echo "fish: $(fish --version)"; echo "tmux: $(tmux -V)"; echo "nvim: $(nvim --version | head -n 1)"; echo "git: $(git --version)"; echo "node: $(node --version)"; echo "npm: $(npm --version)"; echo "npx: $(npx --version)"; echo "jq: $(jq --version)"; echo "uv: $(uv --version)"; if command -v claude >/dev/null 2>&1; then echo "claude: $(claude --version)"; else echo "claude: missing"; exit 1; fi; if command -v codex >/dev/null 2>&1; then echo "codex: $(codex --version)"; else echo "codex: missing optional"; fi'
    run bash -lc 'set -e; test -e "$HOME/.config/fish"; test -e "$HOME/.config/nvim"; test -e "$HOME/.config/tmux"; test -e "$HOME/.claude/settings.json"'
    run fish -lc 'type -q fisher; and echo fisher-ok'
    run fish -lc 'type -q claude; and functions claude >/dev/null; and echo claude-fish-function-ok'
    log "Verification completed"
}

main() {
    log "Log file: $LOG_FILE"
    ensure_path_for_session
    ensure_ubuntu

    if [ "$VERIFY_ONLY" = "1" ]; then
        verify
        exit 0
    fi

    install_apt_packages
    ensure_ubuntu_command_aliases
    ensure_path_for_session
    install_uv
    install_claude_code
    install_neovim
    install_codex
    install_my_dotfiles
    install_claude_dotfiles
    sync_neovim_plugins
    verify

    section "done"
    log "Ubuntu config completed successfully"
    log "Open a new terminal or run: exec fish"
    log "Manual login checks: claude auth status/login if needed, codex login if needed"
}

main "$@"
