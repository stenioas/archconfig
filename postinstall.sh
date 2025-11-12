#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Name        : postinstall.sh
# Description : Arch Linux Post-Installation Script
# Version     : 1.0.0-beta
# Author      : Stenio Silveira <stenioas@gmail.com>
# Date        : 21/10/2025
# License     : GNU/GPL v3.0

# ============================================================================
# INITIALIZATION AND CLEANUP COMMANDS (TRAP/SUDO)
# ============================================================================

set -euo pipefail

trap "tput cnorm" EXIT # Ensures the cursor returns to normal
trap "exit 1" INT      # Ensures the script stops with Ctrl+C
sudo -v                # Ensures the sudo password is ready

# ============================================================================
# FUNCTIONS
# ----------------------------------------------------------------------------

_welcome() {
  clear
  _print_msg "${BCYAN}${BANNER}${RESET}"
  _print_msg "\n Welcome to my ${BCYAN}${SCRIPT_TITLE}${RESET} - v${SCRIPT_VERSION}${RESET}"
  echo

  local msg=$(cat << EOF
 This script is a personal tool. I created it to simplify my life
 and  automate my Arch Linux post-installation process. It reflects
 my choices,  and is not a tutorial or a guide. Feel free to use it,
 adapt, modify, fork, and play around, but use it at your own risk!
 I hope it helps you too!

 See here for more details: https://github.com/stenioas/archinstall
EOF
  )

  local alert=$(cat << EOF
  
 ── ATTENTION! ──────────────────────────────────────────────────────
  The script will run automatically, but you may be asked for your
  password. Stay alert. Please ensure you have read the usage
  instructions entirely before proceeding.
 ────────────────────────────────────────────────────────────────────
EOF
  )
  
  _print_msg "${msg}"
  _print_msg "${BYELLOW}${alert}${RESET}"
}

_finish() {
  _print_msg "\n${BGREEN}All done! ${BCYAN}You can now restart your system.${RESET}"
}

# ============================================================================
# .ENV
# ----------------------------------------------------------------------------

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BANNER=$(cat << 'EOF'
     _    _     ____ ___ ____  
    / \  | |   |  _ \_ _/ ___| 
   / _ \ | |   | |_) | |\___ \ 
  / ___ \| |___|  __/| | ___) |
 /_/   \_\_____|_|  |___|____/ 
EOF
)

SCRIPT_TITLE="Arch Linux Post-Installation Script"
SCRIPT_VERSION="1.0.0-beta"

. ${SCRIPT_DIR}/libs/tput.sh
. ${SCRIPT_DIR}/libs/utils.sh

# ============================================================================
# MAIN
# ----------------------------------------------------------------------------

main() {
  _check_connection
  _welcome
  _pause
  bash ${SCRIPT_DIR}/scripts/configure-pacman.sh
  bash ${SCRIPT_DIR}/scripts/install-aur-packages.sh
  bash ${SCRIPT_DIR}/scripts/install-docker.sh
  bash ${SCRIPT_DIR}/scripts/install-dotfiles.sh
  bash ${SCRIPT_DIR}/scripts/clean-system.sh
  _finish
}

main
