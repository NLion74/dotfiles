#!/bin/bash

DOTFILES_DIR="$(pwd)"

command_exists() {
    command -v "$1" &> /dev/null
}
 
echo "Installing Required programs..."

if command_exists git; then
    echo "Git is already installed."
else
    echo "Git is not installed. Installing Git..."
    if command_exists apt-get; then
        sudo apt-get update && sudo apt-get install git -y
    elif command_exists pacman; then
        sudo pacman -S git --noconfirm
    else
        echo "Unsupported package manager. Please install Git manually."
        exit 1
    fi
fi

if command_exists zsh; then
    echo "Zsh is already installed."
else
    echo "Zsh is not installed. Installing Zsh..."
    if command_exists apt-get; then
        sudo apt-get update && sudo apt-get install zsh -y
    elif command_exists pacman; then
        sudo pacman -S zsh --noconfirm
    else
        echo "Unsupported package manager. Please install Zsh manually."
        exit 1
    fi
fi

if command_exists starship; then
    echo "Starship is already installed."
else
    echo "Starship is not installed. Installing Starship..."
    if command_exists apt-get; then
        sudo apt-get update && sudo apt-get install starship -y
    elif command_exists pacman; then
        sudo pacman -S starship --noconfirm
    else
        curl -sS https://starship.rs/install.sh | sh
    fi
fi

if [ -d "$HOME/.zsh/zinit" ]; then
    echo "Zinit is already installed."
else
    echo "Installing Zinit..."
    git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.zsh/zinit"
fi

chsh -s $(which zsh)

echo "Backing up existing dotfiles..."

if [ -f "$HOME/.zshrc" ]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi
if [ -f "$HOME/.config/starship.toml" ]; then
    mv "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.bak"
fi
if [ -f "$HOME/.local/share/fonts" ]; then
    mv "$HOME/.local/share/fonts" "$HOME/.local/share/fonts.bak"
fi
if [ -d "$HOME/.config/kwinrc" ]; then
    mv "$HOME/.config/kwinrc" "$HOME/.config/kwinrc.bak"
fi
if [ -d "$HOME/.config/kglobalshortcutsrc" ]; then
    mv "$HOME/.config/kglobalshortcutsrc" "$HOME/.config/kglobalshortcutsrc.bak"
fi
if [ -d "$HOME/.config/kdeglobals" ]; then
    mv "$HOME/.config/kdeglobals" "$HOME/.config/kdeglobals.bak"
fi
if [ -d "$HOME/.config/kscreenlockerrc" ]; then
    mv "$HOME/.config/kscreenlockerrc" "$HOME/.config/kscreenlockerrc.bak"
fi
if [ -d "$HOME/.config/plasmarc" ]; then
    mv "$HOME/.config/plasmarc" "$HOME/.config/plasmarc.bak"
fi
if [ -f "$HOME/.config/ksmserverrc" ]; then
    mv "$HOME/.config/ksmserverrc" "$HOME/.config/ksmserverrc.bak"
fi
if [ -f "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" ]; then
    mv "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc.bak"
fi
if [ -d "$HOME/.config/alacritty" ]; then
    mv "$HOME/.config/alacritty" "$HOME/.config/alacritty.bak"
fi
if [ -d "$HOME/.config/neofetch" ]; then
    mv "$HOME/.config/neofetch" "$HOME/.config/neofetch.bak"
fi

echo "Creating symlinks for dotfiles..."

ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/scripts" "$HOME/scripts"
ln -sf "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
ln -sf "$DOTFILES_DIR/.fonts" "$HOME/.fonts"
ln -sf "$DOTFILES_DIR/.config/alacritty" "$HOME/.config/alacritty"
ln -sf "$DOTFILES_DIR/.config/neofetch" "$HOME/.config/neofetch"
cp -sf "$DOTFILES_DIR/.config/kwinrc" "$HOME/.config/kwinrc"
cp -sf "$DOTFILES_DIR/.config/kglobalshortcutsrc" "$HOME/.config/kglobalshortcutsrc"
cp -sf "$DOTFILES_DIR/.config/kdeglobals" "$HOME/.config/kdeglobals"
cp -sf "$DOTFILES_DIR/.config/kscreenlockerrc" "$HOME/.config/kscreenlockerrc"
cp -sf "$DOTFILES_DIR/.config/plasmarc" "$HOME/.config/plasmarc"
cp -sf "$DOTFILES_DIR/.config/ksmserverrc" "$HOME/.config/ksmserverrc"
cp -sf "$DOTFILES_DIR/.config/plasma-org.kde.plasma.desktop-appletsrc" "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

echo "Dotfiles setup complete!"
echo "A reboot to is recommended for changes to take effect"
