#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Name        : configure-pacman.sh
# Description : Pacman Configuration Script
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

IFS=$'\n\t'

. ${SCRIPT_DIR}/../libs/utils.sh

# ============================================================================
# RUN CONFIGURATION
# ----------------------------------------------------------------------------

main() {
  _print_title "Configuring pacman"
  _print_msg "Configuring pacman.conf"
  sudo sed -i '4,$s/^#Color/Color/' /etc/pacman.conf
  sudo sed -i '4,$s/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
  sudo sed -i 's/^ParallelDownloads = [0-9]\+/ParallelDownloads = 20/' /etc/pacman.conf
  sudo sed -i '/^ParallelDownloads/a ILoveCandy' /etc/pacman.conf
  
  # Enable multilib if it exists and is commented
  _print_msg "Enabling multilib repository"
  sudo sed -i '/^#\[multilib\]/{N;s/#\[multilib\]\n#/[multilib]\n/}' /etc/pacman.conf

  _print_msg "Updating mirrorlist"
  sudo reflector -c Brazil --latest 10 --sort rate --verbose --save /etc/pacman.d/mirrorlist

  _print_msg "Configuring pacman completed successfully!"
}

main
