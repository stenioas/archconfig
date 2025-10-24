#!/usr/bin/env python3


import json
import os
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


def collect_builder_modules():
    aur_pkgs, pkgs, cmds = set(), set(), set()

    # Modules
    for module in builder_config.get("modules", []):
        module_path = f"./modules/{module}.jsonc"
        if not os.path.exists(module_path):
            raise KeyError(f"Error: Module file '{module_path}' not found.")
        module_src = load_jsonc(module_path)
        aur_pkgs.update(module_src.get("aur_packages", []))
        pkgs.update(module_src.get("packages", []))
        cmds.update(module_src.get("commands", []))

    return  sorted(aur_pkgs), sorted(pkgs), sorted(cmds)


def main():
    aur_pkgs, pkgs, cmds  = collect_builder_modules()

    def get_list_by_type(list_type):
        if list_type == "pkgs":
            return pkgs
        elif list_type == "cmds":
            return cmds
        elif list_type == "aurpkgs":
            return aur_pkgs
        else:
            print("Invalid list type. Use one of: pkgs, cmds, aurpkgs.")
            exit(1)

    if len(sys.argv) == 3 and sys.argv[1] in ("--list", "-l"):
        list_type = sys.argv[2]
        items = get_list_by_type(list_type)
        print("\n".join(items))
    elif len(sys.argv) == 2 and sys.argv[1] in ("--help", "-h"):
        print("Usage: builder.py --list <pkgs|cmds|aurpkgs> or -l <pkgs|cmds|aurpkgs>")
    else:
        print("Usage: builder.py --list <pkgs|cmds|aurpkgs> or -l <pkgs|cmds|aurpkgs>")

if __name__ == "__main__":
    main()