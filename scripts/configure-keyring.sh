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

LY_PAM_FILE="/etc/pam.d/ly"

# Verifica se o arquivo existe
if [ ! -f "$LY_PAM_FILE" ]; then
    echo "Erro: O arquivo PAM do Ly nao foi encontrado em $LY_PAM_FILE."
    echo "Verifique se o Ly esta instalado."
    exit 1
fi

_print_msg "Iniciando configuracao do PAM para o Ly..."

_print_msg "Corrigindo 'auth'..."
sudo sed -i '/pam_gnome_keyring.so/ s/^-auth/auth/' "$LY_PAM_FILE"

# Corrigir a secao 'password'
_print_msg "Corrigindo 'password'..."
sudo sed -i '/pam_gnome_keyring.so use_authtok/ s/^-password/password/' "$LY_PAM_FILE"

# Corrigir a secao 'session'
_print_msg "Corrigindo 'session'..."
sudo sed -i '/pam_gnome_keyring.so auto_start/ s/^-session/session/' "$LY_PAM_FILE"

_print_msg "Configuracao do PAM concluida com sucesso!"
_print_msg "Voce deve reiniciar o Ly (ou o computador) para que as alteracoes entrem em vigor."
