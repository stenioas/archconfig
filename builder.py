#!/usr/bin/env python3


import json
import sys


def load_jsonc(path):
    """Load a JSON or JSONC file, stripping comments if needed."""
    with open(path, encoding="utf-8") as f:
        lines = []
        for line in f:
            # Remove // comments
            line = line.split('//')[0]
            lines.append(line)
        return json.loads(''.join(lines))


# Load builder config (JSONC)
builder_config = load_jsonc("./builder.config.jsonc")

# Load modules data
aur_modules = load_jsonc("./modules/aur_modules.jsonc")
pacman_modules = load_jsonc("./modules/pacman_modules.jsonc")


def collect_builder_modules():
    pkgs, cmds, aur_pkgs, aur_cmds = set(), set(), set(), set()

    # AUR modules
    for module in builder_config.get("aur", []):
        if module not in aur_modules:
            raise KeyError(f"Module '{module}' not found in AUR modules")
        module_ref = aur_modules[module]
        aur_pkgs.update(module_ref.get("packages", []))
        aur_cmds.update(module_ref.get("commands", []))

    # Pacman modules
    for module in builder_config.get("pacman", []):
        if module not in pacman_modules:
            raise KeyError(f"Module '{module}' not found in pacman modules")
        module_ref = pacman_modules[module]
        pkgs.update(module_ref.get("packages", []))
        cmds.update(module_ref.get("commands", []))

    return sorted(pkgs), sorted(cmds), sorted(aur_pkgs), sorted(aur_cmds)


def main():
    pkgs, cmds, aur_pkgs, aur_cmds = collect_builder_modules()

    def get_list_by_type(list_type):
        if list_type == "pkgs":
            return pkgs
        elif list_type == "cmds":
            return cmds
        elif list_type == "aurpkgs":
            return aur_pkgs
        elif list_type == "aurcmds":
            return aur_cmds
        else:
            print("Invalid list type. Use one of: pkgs, cmds, aurpkgs, aurcmds.")
            exit(1)

    if len(sys.argv) == 3 and sys.argv[1] in ("--list", "-l"):
        list_type = sys.argv[2]
        items = get_list_by_type(list_type)
        print("\n".join(items))
    elif len(sys.argv) == 2 and sys.argv[1] in ("--help", "-h"):
        print("Usage: builder.py --list <pkgs|cmds|aurpkgs|aurcmds> or -l <pkgs|cmds|aurpkgs|aurcmds>")
    else:
        print("Usage: builder.py --list <pkgs|cmds|aurpkgs|aurcmds> or -l <pkgs|cmds|aurpkgs|aurcmds>")

if __name__ == "__main__":
    main()