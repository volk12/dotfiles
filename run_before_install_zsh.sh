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

printf "${BOLD}${CYAN}--- Ensuring ZSH is Installed ---${RESET}\n\n"

ZSH_PATH="/usr/bin/zsh" # Assume /bin is symlinked to /usr/bin

# Check if zsh is already installed
if ! command -v zsh &> /dev/null; then
    printf "${BOLD}${YELLOW}zsh is not installed. Installing...${RESET}\n\n"
    if command -v apt-get &> /dev/null; then # Support Debian / Ubuntu
        sudo apt-get update || { printf "${BOLD}${RED}Error: apt-get update failed. Cannot install zsh.${RESET}\n\n"; exit 1; }
        sudo apt-get install -y zsh || { printf "${BOLD}${RED}Error: Failed to install zsh via apt-get. Aborting setup.${RESET}\n\n"; exit 1; }
    elif command -v dnf &> /dev/null; then # Support Fedora / Red Hat
        sudo dnf install -y zsh || { printf "${BOLD}${RED}Error: Failed to install zsh via dnf. Aborting setup.${RESET}\n\n"; exit 1; }
    elif command -v pacman &> /dev/null; then # Support Arch
        sudo pacman -Sy --noconfirm zsh || { printf "${BOLD}${RED}Error: Failed to install zsh via pacman. Aborting setup.${RESET}\n\n"; exit 1; }
    else
        printf "${BOLD}${RED}Error: Package manager not recognized. Please install zsh manually.${RESET}\n\n"
        exit 1 # Exit the script, as we can't proceed without zsh
    fi
else
    printf "${BOLD}${GREEN}zsh is already installed.${RESET}\n\n"
    # If zsh is found, let's confirm its canonical path for chsh
    ZSH_PATH=$(command -v zsh)
fi

# Check if current shell is zsh
if [ "$SHELL" != "$ZSH_PATH" ]; then
    printf "${BOLD}${YELLOW}Changing shell to zsh...${RESET}\n\n"
    # Use the determined canonical path for zsh
    chsh -s "$ZSH_PATH" "$USER" || { printf "${BOLD}${RED}Error: Failed to change default shell to $ZSH_PATH. You may need to do this manually.${RESET}\n\n"; exit 1; }
    printf "${BOLD}${YELLOW}Please log out and back in for the shell change to take effect.${RESET}\n\n"
else
    printf "${BOLD}${GREEN}Current shell is already zsh.${RESET}\n\n"
fi

printf "${BOLD}${GREEN}--- ZSH Setup Complete ---${RESET}\n\n"