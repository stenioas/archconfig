#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Script   : postinstall.sh
# Descrição: Script de pós-instalação do Pop!_OS 22.04
# Versão   : 1.0.0-beta
# Autor    : Stenio Silveira <stenioas@gmail.com>
# Data     : 21/10/2025
# Licença  : GNU/GPL v3.0
# ============================================================================
# COMANDOS DE INICIALIZAÇÃO E LIMPEZA (TRAP/SUDO)
# ============================================================================

set -euo pipefail

trap "tput cnorm" EXIT # Garante que o cursor volte ao normal
trap "exit 1" INT      # Garante que o script pare com Ctrl+C
sudo -v                # Garante que a senha do sudo esteja pronta

# ============================================================================
# FUNCTIONS
# ----------------------------------------------------------------------------

_welcome() {
  clear
  echo -e "${BCYAN}${BANNER}${RESET}"
  echo -e "\n ${ITALIC}Welcome to my ${BCYAN}${SCRIPT_TITLE}${RESET} - v${ITALIC}${SCRIPT_VERSION}${RESET}"
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
  ${ITALIC}The script will run automatically, but you may be asked for your
  password. Stay alert. Please ensure you have read the usage
  instructions entirely before proceeding.${RESET}${BYELLOW}
 ────────────────────────────────────────────────────────────────────
EOF
  )
  
  echo -e "${ITALIC}${msg}${RESET}"
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

_install_packages() {
  _print_title "Install packages"
  sudo pacman -S --noconfirm "${PKG_LIST[@]}"
}

_install_aur_helpers() {
  _print_title "Install YAY -  AUR helper"
  [[ -d "${TMP_DIR}/yay" ]] && rm -rf "${TMP_DIR}/yay"
  git clone https://aur.archlinux.org/yay.git "${TMP_DIR}/yay"
  cd "${TMP_DIR}/yay"
  makepkg -csi --noconfirm
  cd
}

_install_aur_packages() {
  _print_title "Install AUR packages"
  yay -S --noconfirm "${AUR_PKG_LIST[@]}"
}

_execute_commands() {
  _print_title "Execute additional commands"
  for cmd in "${CMD_LIST[@]}"; do
    _print_msg "Executing command: ${cmd}"
    eval "${cmd}"
  done
}

_clean() {
  _print_msg "Cleaning package cache"
  sudo pacman -Scc
  _print_msg "Removing unnecessary packages"
  sudo pacman -Rns $(pacman -Qdtq) || true
  _print_msg "Removing temporary folder"
  sudo rm -rf "${TMP_DIR}"
}

# ============================================================================
# .ENV
# ----------------------------------------------------------------------------

IFS=$'\n\t'

# AUR PACKAGE LIST
if [[ -f ./builder.py ]]; then
  mapfile -t AUR_PKG_LIST < <(python3 ./builder.py --list aurpkgs)
else
  AUR_PKG_LIST=()
fi

# PACKAGE LIST
if [[ -f ./builder.py ]]; then
  mapfile -t PKG_LIST < <(python3 ./builder.py --list pkgs)
else
  PKG_LIST=()
fi

# COMMAND LIST
if [[ -f ./builder.py ]]; then
  mapfile -t CMD_LIST < <(python3 ./builder.py --list cmds)
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
ITALIC=$(tput sitm)

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
  _install_packages
  _install_aur_helpers
  _install_aur_packages
  _execute_commands
  _clean
}

main
