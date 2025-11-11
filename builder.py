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
    commands, packages, services = set(), set(), set()

    # Modules
    for module in config.get("modules", []):
        module_path = f"./modules/{module}.jsonc"
        if not os.path.exists(module_path):
            raise KeyError(f"Error: Module file '{module_path}' not found.")
        module_src = load_jsonc(module_path)
        commands.update(module_src.get("commands", []))
        packages.update(module_src.get("packages", []))
        services.update(module_src.get("services", []))

    return  commands, sorted(packages), services


def main():

    parser = argparse.ArgumentParser(
        description="List or merge packages, commands, and services from builder modules."
    )
    parser.add_argument(
        "-l", "--list",
        choices=["commands", "packages", "services"],
        help="Type of list required: commands, packages or services. If omitted, will merge and generate main.config.json."
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
        commands, packages, services = collect_builder_modules(builder_config)
        archinstall_config = load_jsonc("./archinstall.config.json")
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(2)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    # Se --list for passado, apenas imprime a lista
    if args.list:
        # Adiciona também os itens do archinstall.config.json
        if args.list == "packages":
            items = set(archinstall_config.get("packages", [])) | set(packages)
        elif args.list == "commands":
            items = set(archinstall_config.get("custom_commands", [])) | set(commands)
        else:
            items = set(archinstall_config.get("services", [])) | set(services)
        if not items:
            return
        print("\n".join(sorted(items)))
        return

    # Se nenhum parâmetro, gera output.config.json mesclando
    merged_config = archinstall_config.copy()
    merged_config["custom_commands"] = list(set(archinstall_config.get("custom_commands", [])) | set(commands))
    merged_config["packages"] = sorted(list(set(archinstall_config.get("packages", [])) | set(packages)))
    merged_config["services"] = sorted(list(set(archinstall_config.get("services", [])) | set(services)))

    with open("output.config.json", "w", encoding="utf-8") as f:
        json.dump(merged_config, f, indent=2, ensure_ascii=False)
    print("output.config.json generated successfully.")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)