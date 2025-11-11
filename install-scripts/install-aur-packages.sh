#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Name        : install-yay.sh
# Description : YAY Installation Script
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

# ============================================================================
# .ENV
# ----------------------------------------------------------------------------

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IFS=$'\n\t'

TMP_DIR="${HOME}/Downloads/TEMP"

declare -a PKG_LIST=(
  "bruno-bin"
  "spotify"
  "visual-studio-code-bin"
  "google-chrome"
)

. ${SCRIPT_DIR}/../libs/utils.lib

# ============================================================================
# RUN INSTALLATION
# ----------------------------------------------------------------------------

main() {
  _print_title "Install YAY AUR helper"
  if pacman -Qi yay &> /dev/null; then
    _print_msg "YAY is already installed"
    return
  fi

  mkdir -p "${TMP_DIR}"
  [[ -d "${TMP_DIR}/yay" ]] && rm -rf "${TMP_DIR}/yay"

  git clone https://aur.archlinux.org/yay.git "${TMP_DIR}/yay"
  cd "${TMP_DIR}/yay"
  makepkg -csi --noconfirm
  cd ${HOME}

  _print_title "Installing AUR packages with YAY"
  yay -S --noconfirm --needed "${PKG_LIST[@]}"
}

main