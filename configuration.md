# Configuration Guide

## Base Archinstall Configuration

This project also includes a base configuration for the official [archinstall](https://archinstall.archlinux.page/index.html) installer. The file `archinstall.config.json` defines essential system settings, such as:

- Kernel selection
- Locale and timezone
- Network configuration
- Mirror and repository settings
- Essential packages
- Custom commands
- Audio configuration

You can customize this file to match your hardware, preferences, and installation requirements. It is used as input for the Archinstall process, ensuring a reproducible and automated base system setup before running post-install scripts and modular configuration.

**Example: `archinstall/archinstall.config.json`**

```jsonc
{
  "kernels": ["linux-lts"],
  "locale_config": {
    "kb_layout": "us-acentos",
    "sys_enc": "UTF-8",
    "sys_lang": "pt_BR.UTF-8"
  },
  "timezone": "America/Fortaleza",
  "network_config": {
    "type": "nm"
  },
  "packages": ["linux-lts-headers", "git", "nano", "reflector"],
  "custom_commands": [
    "reflector -c Brazil --latest 10 --sort rate --save /etc/pacman.d/mirrorlist"
  ],
  "app_config": {
    "audio_config": {
      "audio": "pipewire"
    }
  },
  "mirror_config": {
    "optional_repositories": ["multilib"]
  },
  "services": [],
  "version": "3.0.11"
}
```

See the [example usage](https://archinstall.archlinux.page/installing/guided.html#example-usage) for all available options and adjust as needed for your installation.

### Usage

```bash
archinstall --config archinstall.config.json
```

## Post Install Script

### Features

- Modular configuration: each file in `modules/` is a module with its own package and command lists
- Supports `packages` and `commands` in each module
- Flexible selection of modules for post-install via `builder.config.jsonc`
- Easily extensible for desktops (DE), display managers (DM), graphics (GFX), dotfiles, and custom hardware
- Automated pacman and AUR installation
- Custom post-install commands
- One-command execution for full setup

### Structure

```
archinstall/
├── modules/
│   ├── common.jsonc        # Essential packages/commands for any system
│   ├── custom.jsonc        # Extra packages/commands (e.g. hardware-specific)
│   ├── dotfiles.jsonc      # Dotfiles setup commands
│   ├── de/                 # Desktop environments
│   │   ├── hyprland.jsonc  # Example: Hyprland DE
│   │   └── kde.jsonc       # Example: KDE DE
│   ├── dm/                 # Display managers
│   │   ├── ly.jsonc        # Example: ly DM
│   │   └── sddm.jsonc      # Example: SDDM DM
│   ├── gfx/                # Graphics drivers
│   │   ├── intel.jsonc     # Example: Intel graphics
│   │   └── nvidia.jsonc    # Example: NVIDIA graphics
│   └── ...                 # Add more as needed
├── archinstall.config.json # Archinstall configuration
├── builder.config.jsonc    # Selects which modules to use
├── builder.py              # Merges modules and outputs lists
├── postinstall.sh          # Runs the full post-install automation
├── LICENSE
├── README.md
```

- **modules/**: Each file (or file in a subfolder) is a module. You can define `packages` and `commands` arrays in each.
- **builder.config.jsonc**: Only one property: `modules`, an array listing the modules to include in your post-install. Use subfolder/module notation, e.g. `de/hyprland`.

### Usage

#### 1. Select your modules

Edit `builder.config.jsonc` and set the `modules` array to include the modules you want for your system. Use the format `folder/module` for modules inside subfolders. Example:

```jsonc
{
  "modules": [
    "common", // always included
    "custom", // hardware-specific extras (e.g. sof-firmware for Galaxy Book 4)
    "dotfiles", // dotfiles setup
    "de/hyprland", // desktop environment
    "dm/ly", // display manager
    "gfx/intel" // graphics driver
  ]
}
```

#### 2. Define your modules

Each module file (e.g. `modules/common.jsonc`, `modules/de/hyprland.jsonc`) can contain any of these arrays:

```jsonc
{
  "packages": ["nano", "git", "google-chrome", "spotify"],
  "commands": ["systemctl enable fstrim.timer", "xdg-user-dirs-update"]
}
```

#### 3. Generate package and command lists

Use `builder.py` to output the merged lists:

- `--list packages` : Pacman and AUR packages
- `--list commands` : Post-install commands

**Examples:**

```bash
python3 builder.py --list packages
python3 builder.py --list commands
```

#### 4. Run the post-install script

```bash
bash postinstall.sh
```

This will:

- Check your connection
- Configure temporary folders
- Configure pacman.conf
- Install AUR Helper (YAY)
- Install all pacman and AUR packages
- Execute all post-install commands
- Clean up

### How to Add/Customize Modules

- Create or edit files in `modules/` or its subfolders for each environment, hardware, or configuration you want.
- Use clear names: `common`, `custom`, `dotfiles`, `de/*`, `dm/*`, `gfx/*`, etc.
- Add your packages, AUR packages, and commands to each module as needed.
- Reference only the modules you want in `builder.config.jsonc` using the correct path (e.g. `de/hyprland`).

### Advanced: Custom Commands & Dotfiles

- Add any shell commands to the `commands` array in your module (e.g. enable services, update user dirs, setup dotfiles).
- Use the `dotfiles` module for all your dotfiles setup and configuration commands.

### Troubleshooting

- If a module is missing, the script will show an error and stop.
- Make sure all modules listed in `builder.config.jsonc` exist in the `modules/` folder.
- For builder help, run:
  ```bash
  python3 builder.py --help
  ```

### Contribution

Feel free to fork, open issues, or submit pull requests to improve modularity, add new modules, or enhance automation.

### Requirements

- Archlinux base system
- Python 3
- Bash
- Internet connection for package installation

### License

GNU/GPL v3.0
