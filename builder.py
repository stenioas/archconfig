#!/usr/bin/env python3

import argparse
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


def collect_builder_modules(config):
    pkgs, cmds = set(), set()

    # Modules
    for module in config.get("modules", []):
        module_path = f"./modules/{module}.jsonc"
        if not os.path.exists(module_path):
            raise KeyError(f"Error: Module file '{module_path}' not found.")
        module_src = load_jsonc(module_path)
        pkgs.update(module_src.get("packages", []))
        cmds.update(module_src.get("commands", []))

    return  sorted(pkgs), cmds


def main():
    parser = argparse.ArgumentParser(
        description="List packages or commands from builder modules."
    )
    parser.add_argument(
        "-l", "--list",
        required=True,
        choices=["packages", "commands"],
        help="Type of list required: packages or commands (required)."
    )
    parser.add_argument(
        "-m", "--module",
        metavar="MODULE",
        help="Module name (optional). E.g. de/gnome or gfx/intel. When provided, MODULE is required."
    )

    args = parser.parse_args()

    builder_config = {
        "modules": [args.module]
    } if args.module else load_jsonc("./builder.config.jsonc")

    try:
        pkgs, cmds = collect_builder_modules(builder_config)
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(2)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    items = pkgs if args.list == "packages" else cmds

    if not items:
        return

    print("\n".join(items))

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)