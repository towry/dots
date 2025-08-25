#!/usr/bin/env bash

echo "Danger: This script will delete caches and logs from your system. Proceed with caution!"

# echo command execution 
set -x

rm -rf "$HOME/Library/Caches/mozilla.sccache/"
rm -rf "$HOME/Library/Caches/colima/caches"

rm -rf "$HOME/Library/Caches/Doubao"
rm -rf "$HOME/Library/Caches/anytype-updater/"

## maybe created by the goose project build system.
sudo rm -rf "$HOME/Library/Caches/hermit"

rm -rf "$HOME/Library/Caches/go-build/"

rm -rf "$HOME/Library/Caches/com.tencent.inputmethod.wetype/"
rm -rf "$HOME/Library/Application Support/Code/CachedExtensionVSIXs"
rm -rf "$HOME/Library/Application Support/Google/GoogleUpdater/crx_cache"

rm -rf "$HOME/Library/Application Support/Notion"

rm -rf "$HOME/Library/Application Support/Kerlig"


# goose logs 
rm -rf "$HOME/.local/state/goose/logs"
# nvim logs 
rm -rf "$HOME/.local/state/nvim/*.log"

rm -rf "$HOME/.cache/puppeteer"
rm -rf "$HOME/.cache/npm/_npx"

# rm -rf "$HOME/.cache/uv"
rm -rf "$HOME/.colima/_lima"

rm -rf "$HOME/.lmstudio"
rm -rf "$HOME/.vscode-oss"
rm -rf "$HOME/.bun/install/cache"
rm -rf "$HOME/.amp"

