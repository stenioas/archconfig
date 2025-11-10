#!usr/bin/env bash
# ----------------------------------------------------------------------------

TARGET_DIR="${HOME}/git/github/dotfiles"

# Install dotfiles
if [[ -d ${TARGET_DIR} ]]; then
  echo "Dotfiles folder already exists. A backup will be created in ${TARGET_DIR}_old_$(date +%Y%m%d%H%M%S)."
  mv ${TARGET_DIR} "${TARGET_DIR}_old_$(date +%Y%m%d%H%M%S)"
fi

echo "Cloning and installing dotfiles..."
git clone https://github.com/stenioas/dotfiles.git ${TARGET_DIR}
bash ${TARGET_DIR}/install_dotfiles.sh
