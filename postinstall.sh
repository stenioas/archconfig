#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Name        : postinstall.sh
# Description : Archlinux Post-Installation Script
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
 and  automate my Archlinux post-installation process. It reflects
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

_pause() {
  local pause_msg=" Press any key to continue or [ctrl + c] to exit..."
  echo -e "\n${pause_msg}"

  tput civis
  read -n 1 -s -r
  tput cnorm
}

_print_title() {
  local title="${BYELLOW}${1^^}${RESET}"
  echo -e "\n${title}"
}

_print_msg() {
  local message="${1}..."
  echo -e "${message}"
}

_check_connection() {
  ping -q -w 1 -c 1 8.8.8.8

  if [[ $? -ne 0 ]]; then
    echo -e "You have no connection!"
    exit 1
  fi
}

_configure_environment() {
  _print_msg "Creating temp folder"
  mkdir -p ${TMP_DIR}

  _print_msg "Configuring pacman"
  sudo sed -i '4,$s/^#Color/Color/' /etc/pacman.conf
  sudo sed -i '4,$s/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
  sudo sed -i 's/^ParallelDownloads = [0-9]\+/ParallelDownloads = 20/' /etc/pacman.conf

  _print_msg "Updating mirrorlist"
  sudo reflector -c Brazil --latest 10 --sort rate --verbose --save /etc/pacman.d/mirrorlist
}

_install_aur_helper() {
  _print_title "Install YAY -  AUR helper"
  if pacman -Qi yay &> /dev/null; then
    _print_msg "YAY is already installed"
    return
  fi
  [[ -d "${TMP_DIR}/yay" ]] && rm -rf "${TMP_DIR}/yay"
  git clone https://aur.archlinux.org/yay.git "${TMP_DIR}/yay"
  cd "${TMP_DIR}/yay"
  makepkg -csi --noconfirm
  cd ${HOME}
}

_install_packages() {
  _print_title "Install packages"
  yay -S --noconfirm --needed "${PKG_LIST[@]}"
}

_execute_commands() {
  _print_title "Execute additional commands"
  for cmd in "${CMD_LIST[@]}"; do
    _print_msg "Executing command: ${cmd}"
    eval "${cmd}" || { echo "${BRED}Error:${RESET} Command failed: ${cmd}"; exit 1; }
  done
}

_clean() {
  _print_msg "Cleaning package cache"
  sudo pacman -Scc --noconfirm
  _print_msg "Removing unnecessary packages"
  sudo pacman -Rns $(pacman -Qdtq) || true
  _print_msg "Removing temporary folder"
  sudo rm -rf "${TMP_DIR}"
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

 ┌─┐┌─┐┌─┐┌┬┐  ┬┌┐┌┌─┐┌┬┐┌─┐┬  ┬  ┌─┐┌┬┐┬┌─┐┌┐┌  ┌─┐┌─┐┬─┐┬┌─┐┌┬┐
 ├─┘│ │└─┐ │───││││└─┐ │ ├─┤│  │  ├─┤ │ ││ ││││  └─┐│  ├┬┘│├─┘ │ 
 ┴  └─┘└─┘ ┴   ┴┘└┘└─┘ ┴ ┴ ┴┴─┘┴─┘┴ ┴ ┴ ┴└─┘┘└┘  └─┘└─┘┴└─┴┴   ┴ 
EOF
)

SCRIPT_TITLE="Archlinux Post-Installation Script"
SCRIPT_VERSION="1.0.0-beta"
TMP_DIR="$HOME/Downloads/TEMP"

# COLORS
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Regular Colors
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
PURPLE=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

# Bold Colors
BBLACK=${BOLD}${BLACK}
BRED=${BOLD}${RED}
BGREEN=${BOLD}${GREEN}
BYELLOW=${BOLD}${YELLOW}
BBLUE=${BOLD}${BLUE}
BPURPLE=${BOLD}${PURPLE}
BCYAN=${BOLD}${CYAN}
BWHITE=${BOLD}${WHITE}

# ============================================================================
# MAIN
# ----------------------------------------------------------------------------

main() {
  _check_connection
  _welcome
  _pause
  _configure_environment
  _install_aur_helper
  _install_packages
  _execute_commands
  _clean
}

main
