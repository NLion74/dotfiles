#!/bin/bash

DOTFILES_DIR="$(pwd)"

RECOPY=false

for arg in "$@"; do
    case "$arg" in
        --recopy)
            RECOPY=true
            ;;
    esac
done

command_exists() {
    command -v "$1" &> /dev/null
}

backup() {
    if [ -e "$1" ]; then
        mv "$1" "$1.$(date +%s).bak"
    fi
}

install_pkg() {
    sudo pacman -S --noconfirm --needed "$1"
}

install_aur() {
    local pkg="$1"

    if command_exists paru; then
        paru -S --noconfirm --needed "$pkg"
    elif command_exists yay; then
        yay -S --noconfirm --needed "$pkg"
    else
        echo "No AUR helper found for $pkg."
        echo "Install paru or yay first."
        return 1
    fi
}

copy_dir() {
    src="$1"
    dest="$2"

    mkdir -p "$dest"
    rsync -a --delete "$src"/ "$dest"/
}

copy_file() {
    src="$1"
    dest="$2"

    mkdir -p "$(dirname "$dest")"
    cp -f "$src" "$dest"
}

echo "Installing Required programs..."

for pkg in \
    hyprland \
    hyprpaper \
    hyprsunset \
    waybar \
    wofi \
    dolphin \
    jq \
    socat \
    wl-clipboard \
    cliphist \
    playerctl \
    imagemagick \
    neofetch \
    alacritty \
    starship \
    zsh \
    git \
    python-pywalfox
do
    if command_exists "$pkg"; then
        echo "$pkg is already installed."
    else
        echo "Installing $pkg..."
        install_pkg "$pkg"
    fi
done

for pkg in eww; do
    if command_exists "$pkg"; then
        echo "$pkg is already installed."
    else
        echo "Installing AUR package $pkg..."
        install_aur "$pkg"
    fi
done

if [ -d "$HOME/.zsh/zinit" ]; then
    echo "Zinit is already installed."
else
    echo "Installing Zinit..."
    git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.zsh/zinit"
fi


if [ "$RECOPY" = false ]; then
    echo "Recopying dotfiles..."
    chsh -s "$(which zsh)"
else
    echo "Skipping dotfile copy (--recopy)"
fi

if [ "$RECOPY" = true ]; then
    echo "Skipping SDDM Astronaut Theme (--no-sddm)"
else
    echo "Applying SDDM Astronaut Theme..."
    if command_exists sddm; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
    else
        echo "SDDM not installed. Skipping."
    fi
fi

echo "Backing up existing dotfiles..."

backup "$HOME/.zshrc"
backup "$HOME/.zsh_aliases"
backup "$HOME/.config/starship.toml"
backup "$HOME/.local/share/fonts"
backup "$HOME/.config/alacritty"
backup "$HOME/.config/neofetch"
backup "$HOME/.config/hypr"
backup "$HOME/.config/waybar"
backup "$HOME/.config/wofi"
backup "$HOME/.config/eww"
backup "$HOME/.config/autostart/mount.desktop"
backup "$HOME/.config/dolphinrc"
backup "$HOME/scripts"
backup "$HOME/.fonts"

echo "Copying dotfiles..."

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share"
mkdir -p "$HOME/.config/autostart"
mkdir -p "$HOME/.config/wal/templates"

copy_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
copy_file "$DOTFILES_DIR/.zsh_aliases" "$HOME/.zsh_aliases"

copy_dir "$DOTFILES_DIR/scripts" "$HOME/scripts"

copy_dir "$DOTFILES_DIR/.config/alacritty" "$HOME/.config/alacritty"
copy_dir "$DOTFILES_DIR/.config/neofetch" "$HOME/.config/neofetch"
copy_dir "$DOTFILES_DIR/.config/hypr" "$HOME/.config/hypr"
copy_dir "$DOTFILES_DIR/.config/waybar" "$HOME/.config/waybar"
copy_dir "$DOTFILES_DIR/.config/wofi" "$HOME/.config/wofi"
copy_dir "$DOTFILES_DIR/.config/eww" "$HOME/.config/eww"

copy_dir "$DOTFILES_DIR/.config/wal/templates" "$HOME/.config/wal/templates"

copy_file "$DOTFILES_DIR/.config/dolphinrc" "$HOME/.config/dolphinrc"
copy_file "$DOTFILES_DIR/.config/autostart/mount.desktop" "$HOME/.config/autostart/mount.desktop"

copy_dir "$DOTFILES_DIR/.fonts" "$HOME/.fonts" || echo "Font copy failed"
fc-cache -fv || echo "Font cache update failed"

echo "Dotfiles setup complete!"
echo "Reboot recommended."