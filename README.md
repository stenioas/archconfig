# Archlinux Installation

> 💡 _**This project is a personal tool.** I created it to simplify my life and automate my Archlinux installation process. It reflects my personal choices and is not a tutorial, but rather a documented guide for my own use. Feel free to use it, adapt, modify, fork, and play around, but **use it at your own risk!** I hope it helps you too!_

## Step-by-Step Installation Guide

This section provides a step-by-step guide to install Archlinux using the archinstall tool, the configuration files from this repository, and the `postinstall.sh` script.

For advanced configuration, module customization, and details about the builder system, see the [Configuration Guide](./configuration.md).

### 1. Connect Archinstaller to the Internet via iwctl

- Boot into the Archlinux installer.
- Start the interactive wireless tool:
  ```sh
  iwctl
  ```
- Inside iwctl, run:
  ```sh
  device list
  station <device> scan
  station <device> get-networks
  station <device> connect <SSID>
  exit
  ```
- Test your connection:
  ```sh
  ping archlinux.org
  ```

### 2. Run Reflector to Improve Mirrors

- Update the mirrorlist for faster downloads:
  ```sh
  reflector -c Brazil --latest 10 --sort rate --save /etc/pacman.d/mirrorlist --verbose
  ```
  _(Adjust country as needed)_

### 3. Update Package Database

- Synchronize package databases:
  ```sh
  pacman -Syy
  ```

### 4. Install Git and Nano

- Install essential tools:
  ```sh
  pacman -S git nano
  ```

### 5. Clone the Project

- Clone this repository:
  ```sh
  git clone https://github.com/stenioas/archinstall.git
  cd archinstall
  ```

### 6. Run archinstall with the Project Configuration

- Start the installer with the provided config:
  ```sh
  archinstall --config archinstall.json
  ```

### 7. Configure Partitioning and User Inside Archinstall

- In the archinstall interface:
  - Set up your disk partitioning as desired.
  - Configure your user account and password.

### 8. Install

- Proceed with the installation following the archinstall prompts.
- Wait for the process to complete.
- Reboot

### 9. Reconnect to the Internet After Reboot

- After rebooting into your new Archlinux system, connect to the internet again using `nmtui` (if using Wi-Fi):
  ```sh
  nmtui
  ```

### 10. Clone the Project Again

- Clone this repository again in your new system:
  ```sh
  git clone https://github.com/stenioas/archinstall.git
  cd archinstall
  ```

### 11. Run the Post-Install Script

- Execute the post-install automation script:
  ```sh
  bash postinstall.sh
  ```

## Contribution

Feel free to fork, open issues, or submit pull requests to improve modularity.

## License

GNU/GPL v3.0
