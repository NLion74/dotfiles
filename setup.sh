#!/bin/bash

DOTFILES_DIR="$(pwd)"

command_exists() {
    command -v "$1" &> /dev/null
}

backup() {
    [ -e "$1" ] && mv "$1" "$1.bak"
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
    git
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

chsh -s "$(which zsh)"

echo "Applying SDDM Astronaut Theme..."
if command_exists sddm; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
else
    echo "SDDM not installed. Skipping."
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

echo "Creating symlinks for dotfiles..."

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share"
mkdir -p "$HOME/.config/autostart"

ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.zsh_aliases" "$HOME/.zsh_aliases"
ln -sf "$DOTFILES_DIR/scripts" "$HOME/scripts"

ln -sf "$DOTFILES_DIR/.config/alacritty" "$HOME/.config/alacritty"
ln -sf "$DOTFILES_DIR/.config/neofetch" "$HOME/.config/neofetch"
ln -sf "$DOTFILES_DIR/.config/hypr" "$HOME/.config/hypr"
ln -sf "$DOTFILES_DIR/.config/waybar" "$HOME/.config/waybar"
ln -sf "$DOTFILES_DIR/.config/wofi" "$HOME/.config/wofi"
ln -sf "$DOTFILES_DIR/.config/eww" "$HOME/.config/eww"

ln -sf "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
ln -sf "$DOTFILES_DIR/.config/dolphinrc" "$HOME/.config/dolphinrc"
ln -sf "$DOTFILES_DIR/.config/autostart/mount.desktop" "$HOME/.config/autostart/mount.desktop"

ln -sf "$DOTFILES_DIR/.fonts" "$HOME/.local/share/fonts"
fc-cache -fv

echo "Dotfiles setup complete!"
echo "Reboot recommended."