#!/bin/bash
# run_after_install-tools.sh - Post-chezmoi installation script for new machines
set -euo pipefail # Exit on error, unset variables, pipe errors

echo "--- Running post-chezmoi installation script ---"

# --- Oh My Zsh Installation ---
echo "Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    # --keep-zshrc: Crucial flag to prevent installer from modifying existing .zshrc
    # --unattended: Runs without user interaction (e.g., prompts for .zshrc overwrite)
    # --skip-chsh: Prevents the installer from trying to change the default shell
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc --skip-chsh || true
else
    echo "Oh My Zsh is already installed. Skipping."
fi

# --- Starship Installation ---
echo "Installing Starship..."
# Check if starship is already in PATH
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y # -y for non-interactive
else
    echo "Starship is already installed. Skipping."
fi

# --- FiraCode Nerd Font Installation ---
echo "Installing FiraCode Nerd Font..."
# Check if FiraCode Nerd Font is already installed
if ! fc-list | grep -q "FiraCodeNerdFont"; then
    # Dynamically get the latest release version from GitHub API
    LATEST_RELEASE_TAG=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    
    if [ -z "$LATEST_RELEASE_TAG" ]; then
        echo "Error: Could not determine the latest Nerd Fonts release tag. Skipping font installation."
    else
        echo "Latest Nerd Fonts release detected: $LATEST_RELEASE_TAG"
        FONT_DIR="$HOME/.local/share/fonts/FiraCode" # User-specific font directory
        mkdir -p "$FONT_DIR"

        FONT_ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${LATEST_RELEASE_TAG}/FiraCode.zip"
        TEMP_ZIP_PATH="/tmp/FiraCodeNerdFont_${LATEST_RELEASE_TAG}.zip"

        echo "Downloading FiraCode Nerd Font from: $FONT_ZIP_URL"
        curl -fsSL "$FONT_ZIP_URL" -o "$TEMP_ZIP_PATH"

        echo "Unzipping FiraCode Nerd Font to $FONT_DIR..."
        unzip -o "$TEMP_ZIP_PATH" -d "$FONT_DIR"

        echo "Cleaning up temporary files..."
        rm "$TEMP_ZIP_PATH"

        echo "Refreshing font cache..."
        fc-cache -fv

        echo "FiraCode Nerd Font installed."
    fi
else
    echo "FiraCode Nerd Font already detected. Skipping."
fi

echo "--- Post-chezmoi installation script finished ---"