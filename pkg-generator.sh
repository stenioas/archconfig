#!/usr/bin/env bash

PKG_LIST_FILENAME="./package.list"

COLOR_RED='\033[0;31m'
NC='\033[0m'

if [ ! -f "$PKG_LIST_FILENAME" ]; then
    echo -e "${COLOR_RED}Error:${NC} Package list file not found."
    exit 1
fi

PKG_LIST=($(\
    grep -v '^$' "$PKG_LIST_FILENAME" | \
    sed -E 's/#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//' | \
    grep -v '^$'\
))

PKG_JSON_ARRAY="$(printf '"%s",' "${PKG_LIST[@]}" | sed 's/,$//')"
PKG_JSON_ARRAY="[${PKG_JSON_ARRAY}]"

sed -i ':a;N;$!ba;s|"packages":[[:space:]]*\[[^]]*\]|"packages": '"${PKG_JSON_ARRAY}"'|g' config.json

echo "Package generation completed!"