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

rm -rf "/Users/towry/Library/Application Support/Google/Chrome/Default/Service Worker/CacheStorage"
rm -rf "/Users/towry/Library/Application Support/Google/Chrome/component_crx_cache"
rm -rf "/Users/towry/Library/Application Support/Google/Chrome/extensions_crx_cache"
rm -rf "/Users/towry/Library/Application Support/Google/Chrome/Crashpad"
rm -rf "/Users/towry/workspace/conductor"

rm -rf "/Users/towry/.local/share/octocode"
rm -rf "/Users/towry/.local/share/nvim/mason/packages/basedpyright"
rm -rf "/Users/towry/.local/share/nvim/mason/packages/codelldb"
rm -rf "/Users/towry/.local/share/pnpm/store/v3/files"
rm -rf "/Users/towry/.local/bin/droid"
rm -rf "/Users/towry/.local/bin/octocode"
rm -rf "/Users/towry/.local/bin/expertls"
rm -rf "/Users/towry/.cache/uv/builds-v0"
rm -rf "/Users/towry/workspace/git-repos/test"
rm -rf "/Users/towry/workspace/git-repos/jj"
