#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Name        : install-dotfiles.sh
# Description : Dotfiles Installation Script
# Version     : 0.0.1-beta
# Author      : Stenio Silveira <stenioas@gmail.com>
# Date        : 09/11/2025
# License     : GNU/GPL v3.0

# ============================================================================
# INITIALIZATION AND CLEANUP COMMANDS (TRAP/SUDO)
# ============================================================================

set -euo pipefail

trap "tput cnorm" EXIT # Ensures the cursor returns to normal
trap "exit 1" INT      # Ensures the script stops with Ctrl+C
sudo -v                # Ensures the sudo password is ready

# ============================================================================
# .ENV
# ----------------------------------------------------------------------------

TARGET_DIR="${HOME}/git/github/dotfiles"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IFS=$'\n\t'

. ${SCRIPT_DIR}/../libs/utils.sh

# ============================================================================
# RUN INSTALLATION
# ----------------------------------------------------------------------------

main() {
  _print_title "Dotfiles installation"
  if [[ -d ${TARGET_DIR} ]]; then
    _print_msg "Dotfiles folder already exists. A backup will be created in ${TARGET_DIR}_old_$(date +%Y%m%d%H%M%S)!"
    mv ${TARGET_DIR} "${TARGET_DIR}_old_$(date +%Y%m%d%H%M%S)"
  fi

  _print_msg "Cloning and installing dotfiles from GitHub..."
  git clone https://github.com/stenioas/dotfiles.git ${TARGET_DIR}
  bash ${TARGET_DIR}/install-dotfiles.sh
}

main
