# Name        : tput.sh
# Description : Terminal Formatting Library
# Version     : 0.0.1-beta
# Author      : Stenio Silveira <stenioas@gmail.com>
# Date        : 11/11/2025
# License     : GNU/GPL v3.0
# ============================================================================
# .ENV
# ----------------------------------------------------------------------------

# Format
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
