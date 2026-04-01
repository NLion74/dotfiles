# Arch Hyprland Dotfiles

Personal Arch Linux dotfiles for a Hyprland-based desktop setup with Waybar, Rofi, Eww, Alacritty, Zsh, Pywal, Spicetify, and Nautilus.

### Desktop

![Hyprland desktop screenshot](/assets/screenshot-1.png)

### Rofi & Eww Audio Menu

![Hyprland rofi screenshot](/assets/screenshot-2.png)

### Wallpaper Select

![Hyprland wallpaper select screenshot](/assets/screenshot-3.png)

## Overview

This repository provides a `setup.sh` script that:

- Installs required official Arch packages.
- Installs required AUR packages.
- Clones supporting repositories such as `zinit` and `spicetify-themes`.
- Backs up existing dotfiles before replacing them.
- Copies configs for Hyprland, Waybar, Rofi, Eww, Alacritty, Neofetch, and Zsh.
- Installs local fonts and refreshes the font cache.
- Applies a host-specific Hyprland monitor config.
- Optionally changes the default shell to `zsh`.
- Optionally installs the SDDM Astronaut Theme.

## Requirements

Before running the setup script, make sure you have:

- Arch Linux or an Arch-based distro.
- `sudo` access.
- `git` installed.
- An AUR helper installed, either `paru` or `yay`, if you want AUR packages installed automatically.

## Getting started

Clone the repository and run the setup script:

```bash
git clone https://github.com/NLion74/dotfiles.git
cd dotfiles
chmod +x setup.sh
./setup.sh
```

## Setup modes

The script supports these options:

```bash
./setup.sh --packages-only
./setup.sh --core-only
./setup.sh --skip-shell
./setup.sh --skip-sddm
./setup.sh --skip-monitors
./setup.sh --no-font-cache
./setup.sh --help
```

### Option behavior

- `--packages-only`  
  Only installs packages and clones required repositories. Skips dotfile copying, shell change, SDDM setup, and monitor setup.

- `--core-only`  
  Installs packages, copies dotfiles, and installs monitor config. Skips shell change and SDDM setup.

- `--skip-shell`  
  Does not change the login shell to `zsh`.

- `--skip-sddm`  
  Skips installation of the SDDM Astronaut Theme.

- `--skip-monitors`  
  Skips host-based Hyprland monitor config setup.

- `--no-font-cache`  
  Skips `fc-cache -fv` after copying fonts.

## What gets installed

### Official packages

- `hyprland`
- `hyprpaper`
- `hyprsunset`
- `waybar`
- `rofi`
- `dolphin`
- `jq`
- `socat`
- `wl-clipboard`
- `cliphist`
- `playerctl`
- `imagemagick`
- `alacritty`
- `starship`
- `zsh`
- `git`
- `rsync`
- `nautilus`

### AUR packages

- `neofetch`
- `python-pywalfox`
- `spicetify-cli-git`
- `pywal-spicetify`
- `eww`

### Git repositories cloned by setup

- `https://github.com/zdharma-continuum/zinit.git` → `~/.zsh/zinit`
- `https://github.com/spicetify/spicetify-themes.git` → `~/.config/spicetify/Themes`

## What gets backed up

Existing files and directories are moved into a timestamped backup directory:

```bash
~/.dotfiles-backup/YYYY-MM-DD_HH-MM-SS
```

The script backs up these paths if they already exist:

- `~/.zshrc`
- `~/.zsh_aliases`
- `~/.config/starship.toml`
- `~/.config/alacritty`
- `~/.config/neofetch`
- `~/.config/hypr`
- `~/.config/waybar`
- `~/.config/rofi`
- `~/.config/eww`
- `~/.config/autostart/mount.desktop`
- `~/scripts`
- `~/.fonts`

## What gets copied

The script copies:

- `.zshrc`
- `.zsh_aliases`
- `scripts/`
- `.config/alacritty/`
- `.config/neofetch/`
- `.config/hypr/`
- `.config/waybar/`
- `.config/rofi/`
- `.config/eww/`
- `.config/wal/templates/`
- `.config/autostart/mount.desktop`
- `.fonts/`

## Monitor configuration

The script installs a monitor config based on the hostname:

- Hostnames matching `*nlion-pc*` or `*desktop*` use:
    - `.config/hypr/conf/desktop.conf`
- Hostnames matching `*laptop-jonte*` or `*laptop*` use:
    - `.config/hypr/conf/laptop.conf`

The selected file is installed as:

```bash
~/.config/hypr/conf/monitors.conf
```

## SDDM theme

If SDDM is installed and `--skip-sddm` is not used, the script runs the Astronaut theme installer:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
```

## Notes

- The script is written for Arch-based systems using `pacman`.
- AUR package installation requires `paru` or `yay`.
- Font cache refresh only runs if `fc-cache` exists and `--no-font-cache` is not used.
- The login shell is changed to `zsh` unless `--skip-shell` is passed.
- Nautilus is installed as part of the base package list.
- Pywal templates are copied into `~/.config/wal/templates`.

## Repo status

Work in progress.
