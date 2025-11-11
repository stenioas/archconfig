#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Name        : install-docker.sh
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

IFS=$'\n\t'

. ${SCRIPT_DIR}/../libs/utils.sh

# ============================================================================
# RUN INSTALLATION
# ----------------------------------------------------------------------------

main() {
  _print_title "Install Docker"
  sudo pacman -S --noconfirm --needed docker docker-compose
  _print_msg "Enabling Docker service"
  sudo systemctl enable --now docker
  _print_msg "Adding ${USER} to docker group"
  sudo usermod -aG docker "${USER}"
  _print_msg "Docker installation completed successfully!"
}

main