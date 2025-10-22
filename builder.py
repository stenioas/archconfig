#!/usr/bin/env python3


import json


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
commons_module = load_jsonc("./modules/commons.jsonc")
displays_modules = load_jsonc("./modules/displays.jsonc")
environments_modules = load_jsonc("./modules/environments.jsonc")
graphics_modules = load_jsonc("./modules/graphics.jsonc")


def collect_builder_modules():
    pkgs, cmds, aur_pkgs, aur_cmds = set(), set(), set(), set()

    # AUR modules
    if "aur" not in builder_config:
        raise KeyError(f"Module 'aur' not found in builder config")
    aur_pkgs.update(builder_config.get("aur", {}).get("packages", []))
    aur_cmds.update(builder_config.get("aur", {}).get("commands", []))

    # Custom modules
    if "custom" not in builder_config:
        raise KeyError(f"Module 'custom' not found in builder config")
    pkgs.update(builder_config.get("custom", {}).get("packages", []))
    cmds.update(builder_config.get("custom", {}).get("commands", []))

    # Commons modules
    for module in builder_config.get("modules", {}).get("commons", []):
        if module not in commons_module:
            raise KeyError(f"Module '{module}' not found in commons")
        module_ref = commons_module[module]
        pkgs.update(module_ref.get("packages", []))
        cmds.update(module_ref.get("commands", []))

    # Displays modules
    for module in builder_config.get("modules", {}).get("displays", []):
        if module not in displays_modules:
            raise KeyError(f"Module '{module}' not found in displays")
        module_ref = displays_modules[module]
        pkgs.update(module_ref.get("packages", []))
        cmds.update(module_ref.get("commands", []))

    # Environments modules
    for module in builder_config.get("modules", {}).get("environments", []):
        if module not in environments_modules:
            raise KeyError(f"Module '{module}' not found in environments")
        module_ref = environments_modules[module]
        pkgs.update(module_ref.get("packages", []))
        cmds.update(module_ref.get("commands", []))

    # Graphics modules
    for module in builder_config.get("modules", {}).get("graphics", []):
        if module not in graphics_modules:
            raise KeyError(f"Module '{module}' not found in graphics")
        module_ref = graphics_modules[module]
        pkgs.update(module_ref.get("packages", []))
        cmds.update(module_ref.get("commands", []))

    return sorted(pkgs), sorted(cmds), sorted(aur_pkgs), sorted(aur_cmds)



def output_list_in_file(filename, list):
    """Write the package list to a file, one package per line, without quotes."""
    with open(filename, "w", encoding="utf-8") as f:
        for item in list:
            f.write(f"{item}\n")
    return filename


def main():
    import sys
    pkgs, cmds, aur_pkgs, aur_cmds = collect_builder_modules()

    if len(sys.argv) > 1:
        arg = sys.argv[1]
        file_mode = len(sys.argv) > 2 and sys.argv[2] in ("--file", "-f")

        if arg in ("--commands", "-c"):
            if file_mode:
                output_list_in_file("output_cmds.list", cmds)
            else:
                print("\n".join(cmds))
        elif arg in ("--packages", "-p"):
            if file_mode:
                output_list_in_file("output_pkgs.list", pkgs)
            else:
                print("\n".join(pkgs))
        elif arg in ("--aurpkgs", "-ap"):
            if file_mode:
                output_list_in_file("output_aur_pkgs.list", aur_pkgs)
            else:
                print("\n".join(aur_pkgs))
        elif arg in ("--aurcmds", "-ac"):
            if file_mode:
                output_list_in_file("output_aur_cmds.list", aur_cmds)
            else:
                print("\n".join(aur_cmds))
        else:
            print("Usage: builder.py [--commands|-c|--packages|-p|--aurpkgs|-ap|--aurcmds|-ac] [--file|-f]")
    else:
        print("Usage: builder.py [--commands|-c|--packages|-p|--aurpkgs|-ap|--aurcmds|-ac] [--file|-f]")

if __name__ == "__main__":
    main()