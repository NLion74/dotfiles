#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"

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

if [ -d "$HOME/.zsh/zinit" ]; then
    echo "Zinit is already installed."
else
    echo "Installing Zinit..."
    git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.zsh/zinit"
fi

echo "Backing up existing dotfiles..."

if [ -f "$HOME/.zshrc" ]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi

echo "Creating symlinks for dotfiles..."

ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"

echo "Dotfiles setup complete!"
