#!/bin/bash
set -euo pipefail

AUR_HELPER="paru"

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
RESET='\e[0m'

KEEP_CACHE_VERSIONS=3
SKIP_REFLECTOR=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --skip-reflector)
            SKIP_REFLECTOR=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--skip-reflector]"
            echo
            echo "Options:"
            echo "  --skip-reflector   Skip updating the mirrorlist with reflector"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Warning:${RESET} Unknown option '$arg' (ignored)"
            ;;
    esac
done

echo -e "${RED}Root required for execution.${RESET}"

# Ask for sudo access at the beginning
sudo -v

# Root operations grouped together
sudo bash -euo pipefail <<EOF
set -e

echo -e "${CYAN}Refreshing package database...${RESET}"
pacman -Sy

echo -e "${CYAN}Updating Arch keyring...${RESET}"
pacman -S --noconfirm archlinux-keyring

if [ "$SKIP_REFLECTOR" = false ]; then
    echo -e "${CYAN}Updating mirror list...${RESET}"
    if command -v reflector &> /dev/null; then
        reflector --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
    else
        echo -e "${YELLOW}Reflector not found. Skipping mirror update.${RESET}"
    fi
else
    echo -e "${YELLOW}Skipping mirror update (requested via --skip-reflector).${RESET}"
fi

echo -e "${CYAN}Upgrading system packages...${RESET}"
pacman -Syu --noconfirm

echo -e "${CYAN}Cleaning package cache...${RESET}"
if command -v paccache &> /dev/null; then
    paccache -r -k ${KEEP_CACHE_VERSIONS}
else
    echo -e "${YELLOW}paccache not found. Installing pacman-contrib...${RESET}"
    pacman -S --noconfirm pacman-contrib
    paccache -r -k ${KEEP_CACHE_VERSIONS}
fi

# Remove old journal logs
echo -e "${CYAN}Cleaning journal logs older than 7 days...${RESET}"
journalctl --vacuum-time=7d
EOF

# User-level operations
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

    echo -e "${CYAN}Removing unused Flatpak runtimes...${RESET}"
    flatpak uninstall --unused -y
else
    echo -e "${YELLOW}Flatpak not found. Skipping Flatpak updates.${RESET}"
fi

# Check for needed reboot
echo -e "${GREEN}System update completed.${RESET}"

if [ -f /var/run/reboot-required ]; then
    echo -e "${RED}Reboot required.${RESET}"
else
    echo -e "${GREEN}No reboot required.${RESET}"
fi
