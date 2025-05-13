#!/bin/bash
set -e

AUR_HELPER="paru"
USER_NAME="nlion"

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
RESET='\e[0m'

echo -e "${RED}Root required for execution.${RESET}"

# Ask for sudo access at the beginning
sudo -v

# Root operations grouped together
sudo bash <<'EOF'
echo -e "${CYAN}Refreshing package database...${RESET}"
pacman -Sy

echo -e "${CYAN}Updating Arch keyring...${RESET}"
pacman -S --noconfirm archlinux-keyring

echo -e "${CYAN}Updating mirror list...${RESET}"
if command -v reflector &> /dev/null; then
    reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
else
    echo -e "${YELLOW}Reflector not found. Skipping mirror update.${RESET}"
fi

echo -e "${CYAN}Upgrading system packages...${RESET}"
pacman -Syu --noconfirm

echo -e "${CYAN}Cleaning package cache...${RESET}"
if command -v paccache &> /dev/null; then
    paccache -r
else
    echo -e "${YELLOW}paccache not found. Installing pacman-contrib...${RESET}"
    pacman -S --noconfirm pacman-contrib
    paccache -r
fi
EOF

# User operations AUR
if command -v $AUR_HELPER &> /dev/null; then
    echo -e "${CYAN}Updating AUR packages with $AUR_HELPER...${RESET}"
    $AUR_HELPER -Syu --noconfirm
else
    echo -e "${YELLOW}AUR helper ($AUR_HELPER) not found. Skipping AUR updates.${RESET}"
fi

# Flatpak updates
if command -v flatpak &> /dev/null; then
    echo -e "${CYAN}Updating Flatpak applications...${RESET}"
    flatpak update -y
else
    echo -e "${YELLOW}Flatpak not found. Skipping Flatpak updates.${RESET}"
fi

echo -e "${GREEN}System update completed.${RESET}"
echo -e "${BLUE}Check logs:${RESET} cat /var/log/pacman.log | tail -n 20"
echo -e "${BLUE}Reboot if necessary.${RESET}"
