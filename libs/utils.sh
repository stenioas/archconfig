# Name        : utils.sh
# Description : Utility Functions Library
# Version     : 0.0.1-beta
# Author      : Stenio Silveira <stenioas@gmail.com>
# Date        : 11/11/2025
# License     : GNU/GPL v3.0
# ----------------------------------------------------------------------------

. ./tput.sh

# ----------------------------------------------------------------------------

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
