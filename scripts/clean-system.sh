#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Name        : clean.sh
# Description : Docker Installation Script
# Version     : 0.0.1-beta
# Author      : Stenio Silveira <stenioas@gmail.com>
# Date        : 11/11/2025
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

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. ${SCRIPT_DIR}/../libs/utils.sh

# ============================================================================
# RUN INSTALLATION
# ----------------------------------------------------------------------------

main() {
  _print_title "System Cleanup"
  _print_msg "Cleaning package cache..."
  sudo pacman -Scc --noconfirm
  # Remove orphaned packages only if there are any. pacman -Qdtq exits
  # non-zero when there are no orphans, so capture output with || true
  # and check before calling pacman -Rns to avoid errors.
  local orphans
  orphans=$(pacman -Qdtq || true)
  if [[ -n "${orphans//[[:space:]]/}" ]]; then
    _print_msg "Removing unnecessary packages..."
    sudo pacman -Rns --noconfirm ${orphans}
  else
    _print_msg "No orphaned packages to remove!"
  fi

  _print_msg "System cleanup completed successfully!"
}

main
