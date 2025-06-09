#!/bin/bash

# run_after_install-tools.sh - Post-chezmoi installation script for new machines
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

printf "${BOLD}${CYAN}--- Running post-chezmoi installation script ---${RESET}\n\n"

# --- Oh My Zsh Installation ---
printf "${BOLD}${CYAN}Installing Oh My Zsh...${RESET}\n\n"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    # --keep-zshrc: Crucial flag to prevent installer from modifying existing .zshrc
    # --unattended: Runs without user interaction (e.g., prompts for .zshrc overwrite)
    # --skip-chsh: Prevents the installer from trying to change the default shell
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc --skip-chsh || true
else
    printf "${BOLD}${GREEN}Oh My Zsh is already installed. Skipping.${RESET}\n\n"
fi

# --- Zsh Plugin Installation (Autosuggestions & Syntax Highlighting) ---
# Ensure ZSH_CUSTOM is defined; OMZ usually sets it to $HOME/.oh-my-zsh/custom
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom} 

printf "${BOLD}${CYAN}Installing zsh-autosuggestions plugin...${RESET}\n\n"
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
else
    printf "${BOLD}${GREEN}zsh-autosuggestions already installed. Skipping.${RESET}\n\n"
fi

printf "${BOLD}${CYAN}Installing zsh-syntax-highlighting plugin...${RESET}\n\n"
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
else
    printf "${BOLD}${GREEN}zsh-syntax-highlighting already installed. Skipping.${RESET}\n\n"
fi

# --- Starship Installation ---
printf "${BOLD}${CYAN}Installing Starship...${RESET}\n\n"
# Check if starship is already in PATH
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y # -y for non-interactive
else
    printf "${BOLD}${GREEN}Starship is already installed. Skipping.${RESET}\n\n"
fi

# --- FiraCode Nerd Font Installation ---
printf "${BOLD}${CYAN}Installing FiraCode Nerd Font...${RESET}\n\n"
FONT_INSTALL_DIR="$HOME/.local/share/fonts/FiraCode"
# Check if the font installation directory exists and contains font files
# This is a more robust check than relying solely on fc-list's immediate cache state
if [ ! -d "$FONT_INSTALL_DIR" ] || [ -z "$(find "$FONT_INSTALL_DIR" -maxdepth 1 -type f \( -name "*.ttf" -o -name "*.otf" \) -print -quit)" ]; then
    # Dynamically get the latest release version from GitHub API
    LATEST_RELEASE_TAG=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    
    if [ -z "$LATEST_RELEASE_TAG" ]; then
        printf "${BOLD}${RED}Error: Could not determine the latest Nerd Fonts release tag. Skipping font installation.${RESET}\n\n"
    else
        printf "${BOLD}${CYAN}Latest Nerd Fonts release detected:${RESET} $LATEST_RELEASE_TAG\n\n"
        FONT_DIR="$HOME/.local/share/fonts/FiraCode" # User-specific font directory
        mkdir -p "$FONT_DIR"

        FONT_ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${LATEST_RELEASE_TAG}/FiraCode.zip"
        TEMP_ZIP_PATH="/tmp/FiraCodeNerdFont_${LATEST_RELEASE_TAG}.zip"

        printf "${BOLD}${CYAN}Downloading FiraCode Nerd Font from:${RESET} $FONT_ZIP_URL\n\n"
        curl -fsSL "$FONT_ZIP_URL" -o "$TEMP_ZIP_PATH"

        printf "${BOLD}${CYAN}Unzipping FiraCode Nerd Font to${RESET} $FONT_DIR\n\n"
        unzip -o "$TEMP_ZIP_PATH" -d "$FONT_DIR"

        printf "${BOLD}${CYAN}Cleaning up temporary files...${RESET}\n\n"
        rm "$TEMP_ZIP_PATH"

        printf "${BOLD}${CYAN}Refreshing font cache...${RESET}\n\n"
        fc-cache -fv

        printf "${BOLD}${GREEN}FiraCode Nerd Font installed.${RESET}\n\n"
    fi
else
    printf "${BOLD}${GREEN}FiraCode Nerd Font already detected. Skipping.${RESET}\n\n"
fi

printf "${BOLD}${GREEN}--- Post-chezmoi installation script finished ---${RESET}\n\n"