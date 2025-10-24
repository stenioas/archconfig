# Archinstall Modular Post-Install

Automated post-installation for Arch Linux, with modular package and command management via Python and Bash.

## Features

- Modular configuration via JSONC files (`modules/`)
- Automated pacman and AUR installation
- Custom post-install commands
- Easily extensible for different environments (DEs, graphics, etc.)
- One-command execution for full setup

## Project Structure

```
archinstall/
├── base_configuration.json
modules/
│   ├── aur_modules.jsonc
│   └── pacman_modules.jsonc
.gitignore
builder.config.jsonc
builder.py
LICENSE
postinstall.sh
README.md
```

- **builder.py**: Python script that merges configs and outputs package/command lists.
- **builder.config.jsonc**: Main config file, defines which modules to use and custom/AUR entries.
- **modules/**: Contains modular lists for pacman and AUR packages/commands.
- **postinstall.sh**: Bash script that runs the full post-install automation, using the output from `builder.py`.

## Usage

### 1. Configure your environment

Edit `builder.config.jsonc` to select modules and add pacman/AUR packages and commands.

### 2. Generate package and command lists

The `builder.py` script supports flexible output via flags:

- `--list=<type>` or `-l=<type>`: Print the list to stdout.

Where `<type>` can be:

- `pkgs` or `packages`: Pacman packages
- `cmds` or `commands`: Post-install commands
- `aurpkgs` or `aurpackages`: AUR packages
- `aurcmds` or `aurcommands`: AUR post-install commands

**Examples:**

```bash
python3 builder.py --list pkgs
python3 builder.py -l cmds
```

### 3. Run the post-install script

```bash
bash postinstall.sh
```

This will:

- Check your connection
- Configure environment folders
- Install all pacman and AUR packages
- Execute all post-install commands
- Clean up

## How to Add/Customize Modules

- Edit `modules/pacman_modules.jsonc` and `modules/aur_modules.jsonc` to define new package sets or commands.
- Reference these modules in `builder.config.jsonc` under `"pacman"` and `"aur"` arrays.

**Example builder.config.jsonc:**

```jsonc
{
  "aur": ["softwares"],
  "pacman": ["base", "fonts", "development"]
}
```

## Advanced: Custom Commands

You can add custom shell commands to be executed after installation.  
Add them to the `"commands"` array in your module.

**Example:**

```jsonc
{
  "packages": ["nano", "git"],
  "commands": ["systemctl enable fstrim.timer", "xdg-user-dirs-update"]
}
```

## Troubleshooting

- If a module is missing, the script will show an error and stop.
- Make sure all modules referenced in `builder.config.jsonc` exist in the `modules/` folder.
- For builder help, run:
  ```bash
  python3 builder.py --help
  ```

## Contribution

Feel free to fork, open issues, or submit pull requests to improve modularity, add new environments, or enhance automation.

## Requirements

- Arch Linux base system
- Python 3
- Bash
- Internet connection for package installation

## License

GNU/GPL v3.0
