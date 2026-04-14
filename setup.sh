#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y-%m-%d_%H-%M-%S)"

COPY_FILES=true
ENSURE_PACKAGES=true
SET_SHELL=true
SETUP_SDDM=true
REFRESH_FONTS=true

usage() {
    cat <<'USAGE'
Usage: ./setup.sh [options]

Options:
  --copy-only                 Only back up + copy dotfiles.
  --packages-only             Only ensure packages are installed.
  --core-only                 Ensure packages and copy dotfiles, skip shell + SDDM.
  --skip-shell                Do not change login shell to zsh.
  --skip-sddm                 Do not install/apply SDDM Astronaut Theme.
  --no-font-cache             Do not run fc-cache after copying fonts.
  -h, --help                  Show this help message.
USAGE
}

log() {
    printf '[*] %s\n' "$*"
}

warn() {
    printf '[!] %s\n' "$*" >&2
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

pkg_installed() {
    pacman -Q "$1" >/dev/null 2>&1
}

backup() {
    local target="$1"

    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
        log "Backed up $target"
    fi
}

copy_dir() {
    local src="$1"
    local dest="$2"

    if [ ! -d "$src" ]; then
        warn "Missing directory: $src"
        return 0
    fi

    mkdir -p "$dest"
    rsync -a --delete "$src/" "$dest/"
}

copy_file() {
    local src="$1"
    local dest="$2"

    if [ ! -f "$src" ]; then
        warn "Missing file: $src"
        return 0
    fi

    mkdir -p "$(dirname "$dest")"
    install -m 644 "$src" "$dest"
}

ensure_official_pkg() {
    local pkg="$1"

    if pkg_installed "$pkg"; then
        log "$pkg is already installed"
    else
        log "Installing official package: $pkg"
        sudo pacman -S --noconfirm --needed "$pkg"
    fi
}

ensure_aur_helper() {
    if command_exists paru; then
        printf '%s\n' paru
        return 0
    fi

    if command_exists yay; then
        printf '%s\n' yay
        return 0
    fi

    return 1
}

ensure_aur_pkg() {
    local pkg="$1"
    local helper

    if pkg_installed "$pkg"; then
        log "$pkg is already installed"
        return 0
    fi

    if ! helper="$(ensure_aur_helper)"; then
        warn "No AUR helper found for $pkg (install paru or yay first)"
        return 1
    fi

    log "Installing AUR package: $pkg"
    "$helper" -S --noconfirm --needed "$pkg"
}

ensure_git_repo() {
    local repo_url="$1"
    local dest="$2"

    if [ -d "$dest/.git" ]; then
        log "Repo already present: $dest"
        git -C "$dest" pull --ff-only || warn "Could not update $dest"
        return 0
    fi

    if [ -d "$dest" ] && [ -n "$(find "$dest" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
        warn "Destination exists and is not an empty git repo: $dest"
        warn "Skipping clone to avoid overwriting existing files"
        return 0
    fi

    log "Cloning $repo_url -> $dest"
    mkdir -p "$(dirname "$dest")"
    git clone "$repo_url" "$dest"
}

apply_sddm_theme() {
    if ! command_exists sddm; then
        warn "SDDM not installed. Skipping Astronaut theme."
        return 0
    fi

    log "Applying SDDM Astronaut Theme"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
}

setup_pywal_sync() {
    log "Setting up pywal sync"

    if ! command_exists wal; then
        ensure_official_pkg "python-pywal"
    fi

    wal -i "$HOME/Pictures/wallpaper.jpg"
    spicetify backup apply

    spicetify backup apply

    spicetify config current_theme Dribbblish
    spicetify config color_scheme Dribbblish
    spicetify config inject_css 1
    spicetify config replace_colors 1
    spicetify config inject_theme_js 1
    pywal-spicetify Dribbblish
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --packages-only)
                COPY_FILES=false
                ENSURE_PACKAGES=true
                SET_SHELL=false
                SETUP_SDDM=false
                ;;
            --core-only)
                COPY_FILES=true
                ENSURE_PACKAGES=true
                SET_SHELL=false
                SETUP_SDDM=false
                ;;
            --skip-shell)
                SET_SHELL=false
                ;;
            --skip-sddm)
                SETUP_SDDM=false
                ;;
            --no-font-cache)
                REFRESH_FONTS=false
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                warn "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done
}

main() {
    parse_args "$@"

    local official_packages=(
        hyprland
        hyprpaper
        hyprsunset
        waybar
        rofi
        dolphin
        jq
        socat
        wl-clipboard
        cliphist
        playerctl
        imagemagick
        alacritty
        starship
        zsh
        git
        rsync
        nautilus
        rofimoji
        polkit-gnome
        wtype
    )

    local aur_packages=(
        neofetch
        python-pywalfox
        spicetify-cli-git
        pywal-spicetify
        eww
    )

    if [ "$ENSURE_PACKAGES" = true ]; then
        log "Ensuring required packages are installed"
        for pkg in "${official_packages[@]}"; do
            ensure_official_pkg "$pkg"
        done

        for pkg in "${aur_packages[@]}"; do
            ensure_aur_pkg "$pkg"
        done

        ensure_git_repo "https://github.com/zdharma-continuum/zinit.git" "$HOME/.zsh/zinit"
        ensure_git_repo "https://github.com/spicetify/spicetify-themes.git" "$HOME/.config/spicetify/Themes"
    else
        log "Skipping package installation"
    fi

    if [ "$COPY_FILES" = true ]; then
        log "Backing up existing dotfiles"
        backup "$HOME/.zshrc"
        backup "$HOME/.zsh_aliases"
        backup "$HOME/.config/starship.toml"
        backup "$HOME/.config/alacritty"
        backup "$HOME/.config/neofetch"
        backup "$HOME/.config/hypr"
        backup "$HOME/.config/waybar"
        backup "$HOME/.config/rofi"
        backup "$HOME/.config/eww"
        backup "$HOME/.config/autostart/mount.desktop"
        backup "$HOME/scripts"
        backup "$HOME/.local/share/fonts"
        backup "$HOME/.config/fontconfig"
        backup "$HOME/.config/wal/templates"

        log "Copying dotfiles"
        mkdir -p "$HOME/.config" "$HOME/.local/share" "$HOME/.config/autostart" "$HOME/.config/wal/templates"

        copy_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
        copy_file "$DOTFILES_DIR/.zsh_aliases" "$HOME/.zsh_aliases"
        copy_dir "$DOTFILES_DIR/scripts" "$HOME/scripts"
        copy_dir "$DOTFILES_DIR/.config/alacritty" "$HOME/.config/alacritty"
        copy_dir "$DOTFILES_DIR/.config/neofetch" "$HOME/.config/neofetch"
        copy_dir "$DOTFILES_DIR/.config/hypr" "$HOME/.config/hypr"
        copy_dir "$DOTFILES_DIR/.config/waybar" "$HOME/.config/waybar"
        copy_dir "$DOTFILES_DIR/.config/rofi" "$HOME/.config/rofi"
        copy_dir "$DOTFILES_DIR/.config/eww" "$HOME/.config/eww"
        copy_dir "$DOTFILES_DIR/.config/wal/templates" "$HOME/.config/wal/templates"
        copy_file "$DOTFILES_DIR/.config/autostart/mount.desktop" "$HOME/.config/autostart/mount.desktop"
        copy_dir "$DOTFILES_DIR/.local/share/fonts" "$HOME/.local/share/fonts"
        copy_dir "$DOTFILES_DIR/.config/fontconfig" "$HOME/.config/fontconfig"

        if [ "$REFRESH_FONTS" = true ] && command_exists fc-cache; then
            log "Refreshing font cache"
            fc-cache -fv
        fi
    else
        log "Skipping dotfile copy"
    fi

    if [ "$SET_SHELL" = true ]; then
        if command_exists zsh; then
            log "Changing login shell to zsh"
            chsh -s "$(command -v zsh)"
        else
            warn "zsh is not installed; cannot change shell"
        fi
    else
        log "Skipping shell change"
    fi

    if [ "$SETUP_SDDM" = true ]; then
        apply_sddm_theme
    else
        log "Skipping SDDM theme setup"
    fi

    log "Dotfiles setup complete"
}

main "$@"