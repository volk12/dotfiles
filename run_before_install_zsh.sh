#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail # Exit on error, prevent unset variables, pipe errors

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

echo "Ensuring zsh is installed..."

ZSH_PATH="/usr/bin/zsh" # Assume /bin is symlinked to /usr/bin

# Check if zsh is already installed
if ! command -v zsh &> /dev/null; then
    echo "zsh is not installed. Installing..."
    if command -v apt &> /dev/null; then # Support Debian / Ubuntu
        sudo apt update || { echo "Error: apt update failed. Cannot install zsh."; exit 1; }
        sudo apt install -y zsh || { echo "Error: Failed to install zsh via apt. Aborting setup."; exit 1; }
    elif command -v dnf &> /dev/null; then # Support Fedora / Red Hat
        sudo dnf install -y zsh || { echo "Error: Failed to install zsh via dnf. Aborting setup."; exit 1; }
    elif command -v pacman &> /dev/null; then # Support Arch
        sudo pacman -Sy --noconfirm zsh || { echo "Error: Failed to install zsh via pacman. Aborting setup."; exit 1; }
    else
        echo "Error: Package manager not recognized. Please install zsh manually."
        exit 1 # Exit the script, as we can't proceed without zsh
    fi
else
    echo "zsh is already installed."
    # If zsh is found, let's confirm its canonical path for chsh
    ZSH_PATH=$(command -v zsh)
fi

# Check if current shell is zsh
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Changing shell to zsh..."
    # Use the determined canonical path for zsh
    chsh -s "$ZSH_PATH" "$USER" || { echo "Error: Failed to change default shell to $ZSH_PATH. You may need to do this manually."; exit 1; }
    echo "Please log out and back in for the shell change to take effect."
else
    echo "Current shell is already zsh."
fi

echo "zsh setup complete."