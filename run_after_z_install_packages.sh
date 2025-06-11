#!/bin/bash

# Do NOT use 'set -e' or 'set -o pipefail' to allow individual package
# installations (especially in loops) to fail without stopping the entire script.
# We will rely on explicit '||' error handling for specific commands.
# Only critical initial setup commands will use '|| exit 1'
set -u # Ensure all variables are set

# Define ANSI color/style codes as variables for readability
# Escape sequence for color/style
ESC="\e["
RESET="${ESC}0m" # Reset all attributes
BOLD="${ESC}1m"  # Bold text

# Standard 8 colors (foreground)
RED="${ESC}31m"
GREEN="${ESC}32m"
YELLOW="${ESC}33m"
BLUE="${ESC}34m"
MAGENTA="${ESC}35m"
CYAN="${ESC}36m"

# Bright colors (often equivalent to bold versions of standard colors)
BRIGHT_RED="${ESC}91m"
BRIGHT_GREEN="${ESC}92m"
BRIGHT_YELLOW="${ESC}93m"
BRIGHT_BLUE="${ESC}94m"
BRIGHT_MAGENTA="${ESC}95m"
BRIGHT_CYAN="${ESC}96m"

printf "${BOLD}${CYAN}--- Installing Desired APT Packages ---${RESET}\n\n"

if command -v apt &> /dev/null; then # Support Debian / Ubuntu only for now.
    sudo apt update || printf "${BOLD}${RED}ERROR: apt update failed. Subsequent package installations may be out of date or fail.${RESET}\n\n"

    # List of APT packages
    APT_PACKAGES=(
        tilix
        notvalid # test error case
        # "git"
        # "vim"
        # "tmux"
        # "htop"
    )

    for pkg in "${APT_PACKAGES[@]}"; do
        printf "${BOLD}${CYAN}Installing APT package:${RESET} $pkg\n\n"
        sudo apt install -y "$pkg" || printf "${BOLD}${YELLOW}Warning: Failed to install APT package:${RESET} $pkg${BOLD}${CYAN}. Continuing...${RESET}\n\n"
    done
else
    printf "${BOLD}${RED}ERROR: APT package manager not found. Please install APT packages manually.${RESET}\n\n"
fi

printf "${BOLD}${CYAN}--- Installing Desired Flatpak Packages ---${RESET}\n\n"

# Ensure Flatpak is installed before trying to use it.
if ! command -v flatpak &> /dev/null; then
    printf "${BOLD}${YELLOW}Flatpak is not installed. Installing Flatpak...${RESET}\n\n"
    sudo apt install -y flatpak || { printf "${BOLD}${RED}Error: Failed to install Flatpak via APT. Cannot install Flatpak apps.${RESET}\n\n"; exit 1; }
    # Add Flathub remote:
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || { printf "${BOLD}${RED}Error: Failed to add Flathub remote.${RESET}\n\n"; exit 1; }
fi

# List of desired Flatpak application IDs
FLATPAK_APPS=(
    "com.calibre_ebook.calibre"
    "com.discordapp.Discord"
    "com.github.tchx84.Flatseal"
    "com.jetbrains.IntelliJ-IDEA-Ultimate"
    "com.mattjakeman.ExtensionManager"
    "com.obsproject.Studio"
    "com.slack.Slack"
    "com.valvesoftware.Steam"
    "io.github.pwr_solaar.solaar"
    "md.obsidian.Obsidian"
    "org.audacityteam.Audacity"
    "org.freedesktop.Piper"
    "org.gimp.GIMP"
    "org.gnome.Aisleriot"
    "org.gnome.DejaDup"
    "org.gnome.Mines"
    "org.gnome.Rhythmbox3"
    "org.gnome.Sudoku"
    "org.gnome.meld"
    "org.inkscape.Inkscape"
    "org.openshot.OpenShot"
    "org.signal.Signal"
    "org.stellarium.Stellarium"
    "org.zotero.Zotero"
)

for app_id in "${FLATPAK_APPS[@]}"; do
    printf "${BOLD}${CYAN}Installing Flatpak:${RESET} $app_id\n\n"
    flatpak install flathub "$app_id" -y || printf "${BOLD}${YELLOW}Warning: Failed to install Flatpak:${RESET} $app_id${BOLD}${CYAN}. Continuing...${RESET}\n\n"
done

printf "${BOLD}${GREEN}--- Package Installation Complete ---${RESET}\n\n"