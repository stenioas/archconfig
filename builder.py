#!/usr/bin/env python3


import json
import os
import sys


def load_jsonc(path):
    """Load a JSON or JSONC file, stripping comments if needed."""
    with open(path, encoding="utf-8") as f:
        lines = []
        for line in f:
            line = strip_jsonc_comments(line)
            lines.append(line)
        return json.loads(''.join(lines))


def strip_jsonc_comments(line):
    in_string = False
    result = ''
    i = 0
    while i < len(line):
        if line[i] == '"' and (i == 0 or line[i-1] != '\\'):
            in_string = not in_string
        if not in_string and line[i:i+2] == '//':
            break
        result += line[i]
        i += 1
    return result


# Load builder config (JSONC)
builder_config = load_jsonc("./builder.config.jsonc")


def collect_builder_modules():
    pkgs, cmds = set(), set()

    # Modules
    for module in builder_config.get("modules", []):
        module_path = f"./modules/{module}.jsonc"
        if not os.path.exists(module_path):
            raise KeyError(f"Error: Module file '{module_path}' not found.")
        module_src = load_jsonc(module_path)
        pkgs.update(module_src.get("packages", []))
        cmds.update(module_src.get("commands", []))

    return  sorted(pkgs), cmds


def main():
    pkgs, cmds  = collect_builder_modules()

    def get_list_by_type(list_type):
        if list_type == "packages":
            return pkgs
        elif list_type == "commands":
            return cmds
        else:
            print("Invalid list type. Use one of: packages, commands.")
            exit(1)

    if len(sys.argv) == 3 and sys.argv[1] in ("--list", "-l"):
        list_type = sys.argv[2]
        items = get_list_by_type(list_type)
        print("\n".join(items))
    elif len(sys.argv) == 2 and sys.argv[1] in ("--help", "-h"):
        print("Usage: builder.py --list <packages|commands> or -l <packages|commands>")
    else:
        print("Usage: builder.py --list <packages|commands> or -l <packages|commands>")

if __name__ == "__main__":
    main()