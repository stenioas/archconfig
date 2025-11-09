#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Name        : install-module.sh
# Description : Module Installation Script
# Version     : 0.0.1-beta
# Author      : Stenio Silveira <stenioas@gmail.com>
# Date        : 09/11/2025
# License     : GNU/GPL v3.0

# ============================================================================
# INITIALIZATION AND CLEANUP COMMANDS (TRAP/SUDO)
# ============================================================================

set -euo pipefail

if [ "$#" -ne 1 ]; then
  printf 'Usage: %s module_name\n' "$(basename "$0")" >&2
  exit 2
fi

trap "tput cnorm" EXIT # Ensures the cursor returns to normal
trap "exit 1" INT      # Ensures the script stops with Ctrl+C
sudo -v                # Ensures the sudo password is ready

# ============================================================================
# .ENV
# ----------------------------------------------------------------------------

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IFS=$'\n\t'

MODULE="$1"

# PACKAGE LIST
if [[ -f ${SCRIPT_DIR}/../builder.py ]]; then
  mapfile -t PKG_LIST < <(python3 ${SCRIPT_DIR}/../builder.py --list packages --module "${MODULE}")
else
  PKG_LIST=()
fi

# COMMAND LIST
if [[ -f ${SCRIPT_DIR}/../builder.py ]]; then
  mapfile -t CMD_LIST < <(python3 ${SCRIPT_DIR}/../builder.py --list commands --module "${MODULE}")
else
  CMD_LIST=()
fi

# ============================================================================
# RUN INSTALLATION
# ----------------------------------------------------------------------------

echo "MODULE: ${MODULE}"

# PACKAGES INSTALLATION
echo ":: Install packages:"
yay -S --noconfirm --needed "${PKG_LIST[@]}"

# COMMANDS EXECUTION
echo ":: Execute commands:"
if [[ ${#CMD_LIST[@]} -ne 0 ]]; then
  for cmd in "${CMD_LIST[@]}"; do
    echo "==> Running: ${cmd}"
    eval "${cmd}" || { echo "${BRED}Error:${RESET} Command failed: ${cmd}"; exit 1; }
  done
fi
