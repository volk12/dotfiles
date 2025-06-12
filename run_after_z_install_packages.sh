#!/bin/bash

# Do NOT use 'set -e' or 'set -o pipefail' to allow individual package
# installations (especially in loops) to fail without stopping the entire script.
# We will rely on explicit '||' error handling for specific commands.
# Only critical initial setup commands will use '|| exit 1'
set -u # Ensure all variables are set

# Define ANSI color/style codes as variables for readability
# Escape sequence for color/style
ESC="\033["
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

printf "${BOLD}${CYAN}--- Starting System Setup: Adding Repos, Installing Packages ---${RESET}\n\n"

# ------------------------------------------------------------------------------
# --- 0. Install Core APT Dependencies for Repo Management ---
# ------------------------------------------------------------------------------

# These packages are often needed to add external repositories securely.
# They are installed first to ensure they are available for the repo setup steps.
printf "${BOLD}${CYAN}Installing core dependencies for repository management (curl, gnupg, etc.)...${RESET}\n\n"
if command -v apt-get &> /dev/null; then
    CORE_REPO_DEPS=(
        "curl"
        "wget"
        "gnupg"
        "software-properties-common" # Often needed for add-apt-repository or managing sources
        "apt-transport-https"        # Needed for HTTPS repositories
        "ca-certificates"            # Needed for secure certificate validation
    )
    for dep_pkg in "${CORE_REPO_DEPS[@]}"; do
        printf "${BOLD}${CYAN}Checking and installing core repo dependency: $dep_pkg${RESET}\n\n"
        if ! dpkg -s "$dep_pkg" &> /dev/null; then
            # Package is NOT installed, proceed with installation
            sudo apt-get install -y "$dep_pkg" || printf "${BOLD}${CYAN}Warning: Failed to install core repo dependency: $dep_pkg. Some repo setups may fail.${RESET}\n\n"
        else
            printf "${BOLD}${CYAN}Core repo dependency '$dep_pkg' is already installed. Skipping.${RESET}\n\n"
        fi
    done
else
    printf "${BOLD}${CYAN}Warning: APT package manager not found. Cannot install core repo dependencies.${RESET}\n\n"
fi

# ------------------------------------------------------------------------------
# --- 1. External APT Repositories Setup ---
# ------------------------------------------------------------------------------

printf "${BOLD}${CYAN}Setting up external APT repositories...${RESET}\n\n"

# --- Google Chrome Repository ---
printf "${BOLD}${CYAN}  Setting up Google Chrome repository...${RESET}\n\n"
if [ ! -f /usr/share/keyrings/google-chrome.gpg ]; then
    printf "${BOLD}${CYAN}    Downloading and adding Google Chrome GPG key...${RESET}\n\n"
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | \
        sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg || \
        printf "${BOLD}${RED}    Warning: Failed to add Google Chrome GPG key. Chrome installation may fail later.${RESET}\n\n"
else
    printf "${BOLD}${GREEN}    Google Chrome GPG key already exists.${RESET}\n\n"
fi

if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
    printf "${BOLD}${CYAN}    Adding Google Chrome APT repository...${RESET}\n\n"
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | \
        sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null || \
        printf "${BOLD}${RED}    Warning: Failed to add Google Chrome repository.${RESET}\n\n"
else
    printf "${BOLD}${GREEN}    Google Chrome APT repository already exists.${RESET}\n\n"
fi

# --- Syncthing Repository ---
printf "${BOLD}${CYAN}  Setting up Syncthing repository...${RESET}\n\n"
if [ ! -f /usr/share/keyrings/syncthing-archive-keyring.gpg ]; then
    printf "${BOLD}${CYAN}    Downloading and adding Syncthing GPG key...${RESET}\n\n"
    curl -fsSL https://syncthing.net/release-key.gpg | \
        sudo gpg --dearmor -o /usr/share/keyrings/syncthing-archive-keyring.gpg || \
        printf "${BOLD}${RED}    Warning: Failed to add Syncthing GPG key. Syncthing installation may fail later.${RESET}\n\n"
else
    printf "${BOLD}${GREEN}    Syncthing GPG key already exists.${RESET}\n\n"
fi

if [ ! -f /etc/apt/sources.list.d/syncthing.list ]; then
    printf "${BOLD}${CYAN}    Adding Syncthing APT repository...${RESET}\n\n"
    # Determine the distribution codename (e.g., 'jammy', 'noble')
    DISTRO_CODENAME=$(lsb_release -cs)
    echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | \
        sudo tee /etc/apt/sources.list.d/syncthing.list > /dev/null || \
        printf "${BOLD}${RED}    Warning: Failed to add Syncthing repository.${RESET}\n\n"
    # Syncthing recommends adding the stable repo, not specific to codename for simplicity,
    # but some repos might need: "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing ${DISTRO_CODENAME} stable"
else
    printf "${BOLD}${GREEN}    Syncthing APT repository already exists.${RESET}\n\n"
fi

# +++++++++++++++++++++++++++++++++++++++++++++
# START 1Password BLOCK
# --- 1Password Repository ---
printf "${BOLD}${CYAN}  Setting up 1Password repository...${RESET}\n\n"
if [ ! -f /usr/share/keyrings/1password-archive-keyring.gpg ]; then
    printf "${BOLD}${CYAN}    Downloading and adding 1Password GPG key...${RESET}\n\n"
    curl -fsSL https://downloads.1password.com/linux/keys/1password.asc | \
        sudo gpg --dearmor -o /usr/share/keyrings/1password-archive-keyring.gpg || \
        printf "${BOLD}${RED}    Warning: Failed to add 1Password GPG key. 1Password installation may fail later.${RESET}\n\n"
else
    printf "${BOLD}${GREEN}    1Password GPG key already exists.${RESET}\n\n"
fi

if [ ! -f /etc/apt/sources.list.d/1password.list ]; then
    printf "${BOLD}${CYAN}    Adding 1Password APT repository...${RESET}\n\n"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
        sudo tee /etc/apt/sources.list.d/1password.list > /dev/null || \
        printf "${BOLD}${RED}    Warning: Failed to add 1Password repository.${RESET}\n\n"
else
    printf "${BOLD}${GREEN}    1Password APT repository already exists.${RESET}\n\n"
fi

# --- Add the debsig-verify policy for enhanced security ---
printf "${BOLD}${CYAN}  Adding 1Password debsig-verify policy...${RESET}\n\n"

# Policy directory and file path
DEBSIG_POLICY_DIR="/etc/debsig/policies/AC2D62742012EA22"
DEBSIG_POLICY_FILE="$DEBSIG_POLICY_DIR/1password.pol"
DEBSIG_KEYRING_DIR="/usr/share/debsig/keyrings/AC2D62742012EA22"
DEBSIG_KEYRING_FILE="$DEBSIG_KEYRING_DIR/debsig.gpg"

# Create policy directory if it doesn't exist
if [ ! -d "$DEBSIG_POLICY_DIR" ]; then
    printf "${BOLD}${CYAN}    Creating debsig policy directory: $DEBSIG_POLICY_DIR${RESET}\n\n"
    sudo mkdir -p "$DEBSIG_POLICY_DIR" || \
        printf "${BOLD}${RED}    Warning: Failed to create debsig policy directory. Debsig verification may not work.${RESET}\n\n"
else
    printf "${BOLD}${GREEN}    Debsig policy directory already exists: $DEBSIG_POLICY_DIR${RESET}\n\n"
fi

# Download and add the debsig policy file
if [ ! -f "$DEBSIG_POLICY_FILE" ]; then
    printf "${BOLD}${CYAN}    Downloading and adding debsig policy file...${RESET}\n\n"
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
        sudo tee "$DEBSIG_POLICY_FILE" > /dev/null || \
        printf "${BOLD}${RED}    Warning: Failed to add debsig policy file. Debsig verification may not work.${RESET}\n\n"
else
    printf "${BOLD}${GREEN}    Debsig policy file already exists: $DEBSIG_POLICY_FILE${RESET}\n\n"
fi

# Create debsig keyring directory if it doesn't exist
if [ ! -d "$DEBSIG_KEYRING_DIR" ]; then
    printf "${BOLD}${CYAN}    Creating debsig keyring directory: $DEBSIG_KEYRING_DIR${RESET}\n\n"
    sudo mkdir -p "$DEBSIG_KEYRING_DIR" || \
        printf "${BOLD}${RED}    Warning: Failed to create debsig keyring directory. Debsig verification may not work.${RESET}\n\n"
else
    printf "${BOLD}${GREEN}    Debsig keyring directory already exists: $DEBSIG_KEYRING_DIR${RESET}\n\n"
fi

# Download and add the debsig verification key
if [ ! -f "$DEBSIG_KEYRING_FILE" ]; then
    printf "${BOLD}${CYAN}    Downloading and adding debsig verification key...${RESET}\n\n"
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
        sudo gpg --dearmor --output "$DEBSIG_KEYRING_FILE" || \
        printf "${BOLD}${RED}    Warning: Failed to add debsig verification key. Debsig verification may not work.${RESET}\n\n"
else
    printf "${BOLD}${GREEN}    Debsig verification key already exists: $DEBSIG_KEYRING_FILE${RESET}\n\n"
fi
# --- END 1Password BLOCK
# +++++++++++++++++++++++++++++++++++++

# --- Fastfetch Repository ---
printf "${BOLD}${CYAN}  Setting up Fastfetch repository...${RESET}\n\n"

# 1. Add Fastfetch GPG key

        printf "${BOLD}${RED}    Warning: Failed to add Fastfetch GPG key. Fastfetch installation may fail later.${RESET}\n\n"
else
    printf "${BOLD}${GREEN}    Fastfetch GPG key already exists.${RESET}\n\n"
fi

# 2. Add Fastfetch APT repository to sources
if [ ! -f /etc/apt/sources.list.d/fastfetch.list ]; then
    printf "${BOLD}${CYAN}    Adding Fastfetch APT repository...${RESET}\n\n"
    DISTRO_CODENAME=$(lsb_release -cs) # Get the distribution codename (e.g., jammy, noble)
    echo "deb [signed-by=/usr/share/keyrings/fastfetch-archive-keyring.gpg] https://ppa.launchpadcontent.net/zhangsongcui3371/fastfetch/ubuntu/ ${DISTRO_CODENAME} main" | \
        sudo tee /etc/apt/sources.list.d/fastfetch.list > /dev/null || \
        printf "${BOLD}${RED}    Warning: Failed to add Fastfetch repository.${RESET}\n\n"
else
    printf "${BOLD}${GREEN}    Fastfetch APT repository already exists.${RESET}\n\n"
fi

# --- Speedtest CLI Repository ---
printf "${BOLD}${CYAN}  Setting up Speedtest CLI repository...${RESET}\n\n"

# The official script from packagecloud.io should handle adding the GPG key
# and the .list file automatically. We'll check for a common file it creates
# to ensure idempotency.
SPEEDTEST_REPO_FILE="/etc/apt/sources.list.d/ookla_speedtest-cli.list" 

if [ ! -f "$SPEEDTEST_REPO_FILE" ]; then
    printf "${BOLD}${CYAN}    Running official Speedtest CLI repository setup script...${RESET}\n\n"
    # Execute the official script to add the repo and key
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash || \
        printf "${BOLD}${RED}    Warning: Failed to run Speedtest CLI repository setup script. Speedtest installation may fail later.${RESET}\n\n"
else
    printf "${BOLD}${GREEN}    Speedtest CLI APT repository already exists.${RESET}\n\n"
fi

# --- Add more repositories here ---
# For example:
# printf "${BOLD}${CYAN}  Setting up Another App repository...${RESET}\n\n"
# ... (GPG key and sources.list.d entry for "Another App") ...


printf "${BOLD}${CYAN}External APT repositories setup complete. Updating package lists...${RESET}\n\n"

# ------------------------------------------------------------------------------
# --- 2. Update APT Package Lists and install APT packages ---
# ------------------------------------------------------------------------------

printf "${BOLD}${CYAN}--- Installing Desired APT Packages ---${RESET}\n\n"

if command -v apt &> /dev/null; then # Support Debian / Ubuntu only for now.
    sudo apt-get update || printf "${BOLD}${RED}ERROR: apt update failed. Subsequent package installations may be out of date or fail.${RESET}\n\n"

    # List of APT packages
    APT_PACKAGES=(
        # Core tools
        "tilix"
        "btop"
        "virt-manager"
        "code"
        "fastfetch"
        "speedtest"
        "1password"

        # Browsers
        "google-chrome-stable"

        # File Sync & Backup
        "syncthing"
    )

    for pkg in "${APT_PACKAGES[@]}"; do
        printf "${BOLD}${CYAN}Checking and installing APT package:${RESET} $pkg\n\n"
        if ! dpkg -s "$pkg" &> /dev/null; then
            # Package is NOT installed, proceed with installation
            sudo apt-get install -y "$pkg" || printf "${BOLD}${YELLOW}Warning: Failed to install APT package:${RESET} $pkg ${BOLD}${CYAN}Continuing...${RESET}\n\n"
        else
            printf "Package '$pkg' is already installed. Skipping."
        fi
    done
else
    printf "${BOLD}${RED}ERROR: APT package manager not found. Please install APT packages manually.${RESET}\n\n"
fi

# ------------------------------------------------------------------------------
# --- 3. Install Flatpak Packages ---
# ------------------------------------------------------------------------------

printf "${BOLD}${CYAN}--- Installing Desired Flatpak Packages ---${RESET}\n\n"

# Ensure Flatpak is installed before trying to use it.
if ! command -v flatpak &> /dev/null; then
    printf "${BOLD}${YELLOW}Flatpak is not installed. Installing Flatpak...${RESET}\n\n"
    sudo apt-get install -y flatpak || { printf "${BOLD}${RED}Error: Failed to install Flatpak via APT. Cannot install Flatpak apps.${RESET}\n\n"; exit 1; }
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
    flatpak install flathub "$app_id" -y || printf "${BOLD}${YELLOW}Warning: Failed to install Flatpak:${RESET} $app_id ${BOLD}${CYAN}Continuing...${RESET}\n\n"
done

printf "${BOLD}${GREEN}--- Package Installation Complete ---${RESET}\n\n"