#!/usr/bin/env python3

import json

def load_jsonc(path):
    """Load a JSON or JSONC file, stripping comments if needed."""
    with open(path, encoding="utf-8") as f:
        lines = []
        for line in f:
            # Remove // and # comments
            line = line.split('//')[0].split('#')[0]
            lines.append(line)
        return json.loads(''.join(lines))

# Load archinstall config (standard JSON)
with open("./archinstall.json", encoding="utf-8") as f:
    archinstall_config = json.load(f)

# Load builder config (JSONC)
builder_config = load_jsonc("./builder.config.jsonc")

# Load modules data
base_modules = load_jsonc("./modules/base.jsonc")
environments_modules = load_jsonc("./modules/environments.jsonc")
graphics_modules = load_jsonc("./modules/graphics.jsonc")

def collect_builder_modules():
    pkgs, svcs, cmds = set(), set(), set()

    # Base
    for module in builder_config.get("modules", {}).get("base", []):
        module_ref = None
        if module in base_modules:
            module_ref = base_modules[module]
        if module_ref:
            pkgs.update(module_ref.get("packages", []))
            svcs.update(module_ref.get("services", []))
            cmds.update(module_ref.get("custom_commands", []))

    # Environments
    for module in builder_config.get("modules", {}).get("environments", []):
        module_ref = None
        if module in environments_modules:
            module_ref = environments_modules[module]
        if module_ref:
            pkgs.update(module_ref.get("packages", []))
            svcs.update(module_ref.get("services", []))
            cmds.update(module_ref.get("custom_commands", []))

    # Graphics
    for module in builder_config.get("modules", {}).get("graphics", []):
        module_ref = None
        if module in graphics_modules:
            module_ref = graphics_modules[module]
        if module_ref:
            pkgs.update(module_ref.get("packages", []))
            svcs.update(module_ref.get("services", []))
            cmds.update(module_ref.get("custom_commands", []))

    return sorted(pkgs), sorted(svcs), sorted(cmds)

if __name__ == "__main__":
    pkgs, svcs, cmds = collect_builder_modules()

    # Create a copy of archinstall_config to avoid modifying the original
    config = archinstall_config.copy()
    config["packages"] = pkgs
    config["services"] = svcs
    config["custom_commands"] = cmds

    with open("config.json", "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)