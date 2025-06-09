#!/bin/bash

# Don't use 'set -e' to allow individual package installations to fail without stopping the whole script
# Only critical initial setup commands will use '|| exit 1'

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

echo "Installing desired APT packages..."

if command -v apt &> /dev/null; then # Support Debian / Ubuntu only for now.
    sudo apt update || echo "Warning: apt update failed. Subsequent package installations may be out of date or fail."

    # List of APT packages
    APT_PACKAGES=(
        # "git"
        # "vim"
        # "tmux"
        # "htop"
        # "build-essential"
        # Add all your desired APT packages here
    )

    for pkg in "${APT_PACKAGES[@]}"; do
        echo "Installing APT package: $pkg"
        sudo apt install -y "$pkg" || echo "Warning: Failed to install APT package: $pkg. Continuing..."
    done
else
    echo "Warning: APT package manager not found. Please install APT packages manually."
fi

echo "Installing desired Flatpak packages..."

# Ensure Flatpak is installed before trying to use it.
if ! command -v flatpak &> /dev/null; then
    echo "Flatpak is not installed. Installing Flatpak..."
    sudo apt install -y flatpak || { echo "Error: Failed to install Flatpak via APT. Cannot install Flatpak apps."; exit 1; }
    # Add Flathub remote here if you haven't already:
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || { echo "Error: Failed to add Flathub remote."; exit 1; }
fi

# List of your desired Flatpak application IDs
FLATPAK_APPS=(
    # "org.gnome.Boxes"
    # "com.spotify.Client"
    # "org.gimp.GIMP"
    # Add all your desired Flatpak application IDs here
)

for app_id in "${FLATPAK_APPS[@]}"; do
    echo "Installing Flatpak: $app_id"
    flatpak install flathub "$app_id" -y || echo "Warning: Failed to install Flatpak: $app_id. Continuing..."
done

echo "Package installation complete."