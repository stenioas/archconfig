#!usr/bin/env bash
# ----------------------------------------------------------------------------

# Install dotfiles
if [[ -d ${HOME}/.dotfiles ]]; then
  echo "Dotfiles already installed."
  exit 0
else
  echo "Cloning and installing dotfiles..."
  git clone https://github.com/stenioas/dotfiles.git ${HOME}/.dotfiles
  bash ${HOME}/.dotfiles/install_dotfiles.sh
fi
