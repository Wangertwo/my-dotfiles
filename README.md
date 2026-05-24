# my-dotfiles

Linux Ubuntu dotfiles for fish, tmux, and Neovim.

## What `install.sh` does

Running `install.sh` on Ubuntu will:

1. install required Ubuntu packages with `apt-get`;
2. create `bat` and `fd` command aliases for Ubuntu package names when needed;
3. back up existing local config paths with a `backup-YYYYmmddHHMMSS` suffix;
4. symlink this repository into:
   - `~/.config/fish`
   - `~/.config/nvim`
   - `~/.config/tmux`
   - `~/.tmux.conf`
5. install fish plugins listed in `.config/fish/fish_plugins`;
6. try to set fish as the default shell;
7. run Neovim headless plugin synchronization with `Lazy! sync`.

The installer is intentionally Ubuntu-focused. It exits on unsupported systems instead of partially applying the configuration.

## Fresh Ubuntu setup

```bash
sudo apt-get update
sudo apt-get install -y git sudo

git clone https://github.com/Wangertwo/my-dotfiles.git ~/my-dotfiles
cd ~/my-dotfiles
./install.sh
```

After the installer finishes, open a new terminal or run:

```bash
exec fish
```

## Existing config backup behavior

If these paths already exist and are not symlinks, the installer renames them before linking this repository:

- `~/.config/fish`
- `~/.config/nvim`
- `~/.config/tmux`
- `~/.tmux.conf`

Example backup name:

```text
~/.config/nvim.backup-20260525040122
```

If the path is already a symlink, the installer removes the symlink and recreates it.

## Private machine-local settings

Do not commit secrets to this repository.

For fish-local environment variables, use:

```bash
nvim ~/.config/fish/.env
```

`.env`, `.env.*`, and `private.fish` are ignored by git. The fish setup step creates `~/.config/fish/.env` if it does not exist.

## Updating this repository from an already-configured machine

Because the live config paths are symlinks into the repository after installation, edit files in either location and commit from the repository:

```bash
cd ~/my-dotfiles
git status
git add .
git commit -m "Update dotfiles"
git push
```

## Re-running the installer

The installer is safe to re-run. It replaces existing symlinks and backs up real files or directories before creating new links.

```bash
cd ~/my-dotfiles
./install.sh
```

## Notes

- `install.sh` may prompt for the sudo password when installing packages or changing the default shell.
- Neovim plugins are installed by the final headless `Lazy! sync` step.
- Optional tools used by some shortcuts, such as `lazygit` or `yazi`, may still need separate installation if you use those specific shortcuts.
