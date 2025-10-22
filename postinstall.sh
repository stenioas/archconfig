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

_hex_to_foreground_rgb() {
    local hex_code="$1"
    # Remove '#'
    hex_code="${hex_code##\#}" 
    
    # Extrai R, G, B em decimal
    local r=$(printf "%d" 0x"${hex_code:0:2}")
    local g=$(printf "%d" 0x"${hex_code:2:2}")
    local b=$(printf "%d" 0x"${hex_code:4:2}")

    # Usa printf para garantir que a sequência de escape seja correta.
    # %s é para as variáveis (r, g, b), e o '\e' é a sequência de escape.
    printf '\e[38;2;%s;%s;%sm' "$r" "$g" "$b"
}

_hex_to_background_rgb() {
    local hex_code="$1"
    # Remove '#'
    hex_code="${hex_code##\#}" 
    
    # Extrai R, G, B em decimal
    local r=$(printf "%d" 0x"${hex_code:0:2}")
    local g=$(printf "%d" 0x"${hex_code:2:2}")
    local b=$(printf "%d" 0x"${hex_code:4:2}")

    # Usa printf para garantir que a sequência de escape seja correta.
    # %s é para as variáveis (r, g, b), e o '\e' é a sequência de escape.
    printf '\e[48;2;%s;%s;%sm' "$r" "$g" "$b"
}

_welcome() {
  clear
  echo -e "${COLOR_LIGHT_MAIN}${BANNER}${RESET}"
  echo -e "\n Welcome to ${COLOR_LIGHT_MAIN}${SCRIPT_TITLE} - v${SCRIPT_VERSION}${RESET}"
  echo

  local msg=$(cat << EOF
 Automates post-installation, setting up my software and configuring
 my entire environment. Feel free to modify and adapt it to your needs.

 See here for more details: https://github.com/stenioas/archinstall
EOF
  )

  local alert=$(cat << EOF
  
╭─ ATTENTION! ───────────────────────────────────────────────────────────╮
│ The script will run automatically, but you may be asked for your       │
│ password. Stay alert. Please ensure you have read the usage            │
│ instructions entirely before proceeding.                               │
╰────────────────────────────────────────────────────────────────────────╯
EOF
  )
  
  echo -e "${ITALIC}${msg}${RESET}"
  echo -e "${COLOR_LIGHT_YELLOW}${alert}${RESET}"
}

_pause() {
  local pause_msg=" Press any key to continue or [ctrl + c] to exit..."
  echo -e "\n${pause_msg}"

  tput civis
  read -n 1 -s -r
  tput cnorm
}

_print_title() {
  local title="${BOLD}${COLOR_LIGHT_YELLOW}${1^^}${RESET}"
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

alpis_log_prefix() {
  sed "s/^/${COLOR_LIGHT_MAIN}[alpis]: ${RESET}/"
}

_configure_environment() {
  _print_msg "Creating temp folder"
  mkdir -p ${HOME}/Downloads/temp
}

_install_packages() {
  _print_title "Install packages"
  sudo pacman -S --noconfirm "${PKG_LIST[@]}"
}

_install_aur_helpers() {
  _print_title "Install YAY -  AUR helper"
  [[ -d yay ]] && rm -rf yay
  git clone https://aur.archlinux.org/yay.git $TMP_DIR/yay
  cd $TMP_DIR/yay
  makepkg -csi --noconfirm
  cd
}

_install_aur_packages() {
  _print_title "Install AUR packages"
  git clone https://aur.archlinux.org/yay.git $TMP_DIR/yay
  cd $TMP_DIR/yay
  makepkg -si --noconfirm
  yay -S --noconfirm ${AUR_PKG_LIST[@]}
}

_execute_commands() {
  _print_title "Execute additional commands"
  for cmd in "${CMD_LIST[@]}"; do
    _print_msg "Executing command: ${cmd}"
    eval "${cmd}"
  done

  for aur_cmd in "${AUR_CMD_LIST[@]}"; do
    _print_msg "Executing AUR command: ${aur_cmd}"
    eval "${aur_cmd}"
  done
}

_clean() {
  _print_msg "Cleaning package cache"
  sudo pacman -Scc
  _print_msg "Removing unnecessary packages"
  sudo pacman -Rns $(pacman -Qdtq) || true
  _print_msg "Removing temporary folder"
  sudo rm -rf "$TMP_DIR"
}

# ============================================================================
# .ENV
# ----------------------------------------------------------------------------

IFS=$'\n\t'

# PACKAGE LIST
if [[ -f ./builder.py ]]; then
  mapfile -t PKG_LIST < <(python3 ./builder.py --packages)
else
  PKG_LIST=()
fi

# COMMAND LIST
if [[ -f ./builder.py ]]; then
  mapfile -t CMD_LIST < <(python3 ./builder.py --commands)
else
  CMD_LIST=()
fi

# AUR PACKAGE LIST
if [[ -f ./builder.py ]]; then
  mapfile -t AUR_PKG_LIST < <(python3 ./builder.py --aurpkgs)
else
  AUR_PKG_LIST=()
fi

# AUR COMMAND LIST
if [[ -f ./builder.py ]]; then
  mapfile -t AUR_CMD_LIST < <(python3 ./builder.py --aurcmds)
else
  AUR_CMD_LIST=()
fi

BANNER=$(cat << 'EOF'

 █████╗ ██╗     ██████╗ ██╗███████╗
██╔══██╗██║     ██╔══██╗██║██╔════╝
███████║██║     ██████╔╝██║███████╗
██╔══██║██║     ██╔═══╝ ██║╚════██║
██║  ██║███████╗██║     ██║███████║
╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚══════╝
EOF
)

SCRIPT_TITLE="Arch Linux Post-Installation Script"
SCRIPT_VERSION="1.0.0-beta"
TMP_DIR="/tmp/alpis"

# COLORS
RESET=$(printf "\e[0m")
BOLD=$(printf "\e[1m")
ITALIC=$(printf "\e[3m")
COLOR_LIGHT_MAIN=$(_hex_to_foreground_rgb "#1793D0")
COLOR_DARK_MAIN=$(_hex_to_foreground_rgb "#D01792")
COLOR_LIGHT_RED=$(_hex_to_foreground_rgb "#F15D22")
COLOR_DARK_RED=$(_hex_to_foreground_rgb "#CC0000")
COLOR_LIGHT_YELLOW=$(_hex_to_foreground_rgb "#FFCE51")
COLOR_DARK_YELLOW=$(_hex_to_foreground_rgb "#C4A000")
COLOR_LIGHT_CYAN=$(_hex_to_foreground_rgb "#34E2E2")
COLOR_DARK_CYAN=$(_hex_to_foreground_rgb "#06989A")
COLOR_GREY=$(_hex_to_foreground_rgb "#88807C")
COLOR_LIGHT_GREY=$(_hex_to_foreground_rgb "#D3D7CF")
COLOR_DARK_GREY=$(_hex_to_foreground_rgb "#4C4C4C")
COLOR_BLUE_AZURE=$(_hex_to_foreground_rgb "#0B96FF")
COLOR_DARK_GREEN=$(_hex_to_foreground_rgb "#C4A000")
COLOR_TEA=$(_hex_to_foreground_rgb "#73C48F")

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
