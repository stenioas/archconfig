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
  echo -e "${BCYAN}${BANNER}${RESET}"
  echo -e "\n Welcome to my ${BCYAN}${SCRIPT_TITLE}${RESET} - v${SCRIPT_VERSION}${RESET}"
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
  
  echo -e "${msg}"
  echo -e "${BYELLOW}${alert}${RESET}"
}

_finish() {
  _print_msg "Cleaning package cache"
  sudo pacman -Scc --noconfirm
  # Remove orphaned packages only if there are any. pacman -Qdtq exits
  # non-zero when there are no orphans, so capture output with || true
  # and check before calling pacman -Rns to avoid errors.
  local orphans
  orphans=$(pacman -Qdtq || true)
  if [[ -n "${orphans//[[:space:]]/}" ]]; then
    _print_msg "Removing unnecessary packages"
    sudo pacman -Rns --noconfirm ${orphans}
  else
    _print_msg "No orphaned packages to remove"
  fi

  echo -e "\n${BGREEN}All done!${RESET} You can now restart your system."
}

# ============================================================================
# .ENV
# ----------------------------------------------------------------------------

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IFS=$'\n\t'

# PACKAGE LIST
if [[ -f ${SCRIPT_DIR}/builder.py ]]; then
  mapfile -t PKG_LIST < <(python3 ${SCRIPT_DIR}/builder.py --list packages)
else
  PKG_LIST=()
fi

# COMMAND LIST
if [[ -f ${SCRIPT_DIR}/builder.py ]]; then
  mapfile -t CMD_LIST < <(python3 ${SCRIPT_DIR}/builder.py --list commands)
else
  CMD_LIST=()
fi

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
  _finish
}

main
