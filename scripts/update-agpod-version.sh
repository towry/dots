#!/usr/bin/env bash
# Update agpod to a new version by fetching release info from GitHub

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

AGPOD_NIX_FILE="${SCRIPT_DIR}/../nix/pkgs/agpod.nix"
VERSIONS_JSON_FILE="${SCRIPT_DIR}/../nix/pkgs/versions.json"
REPO="towry/agpod"

function usage {
  echo "Usage: $0 <version>"
  echo "Example: $0 0.8.0"
  exit 1
}

function get_current_version {
  jq -r '.agpod' "${VERSIONS_JSON_FILE}"
}

function fetch_release_info {
  local version=$1
  gh release view "v${version}" --repo "${REPO}" --json assets,url
}

function extract_download_url {
  local json=$1
  echo "${json}" | jq -r '.assets[] | select(.name | contains("aarch64-apple-darwin.tar.gz")) | .url'
}

function fetch_and_compute_hash {
  local url=$1
  nix-prefetch-url "${url}"
}

function update_version_in_json {
  local new_version=$1
  
  jq --arg version "${new_version}" '.agpod = $version' "${VERSIONS_JSON_FILE}" > "${VERSIONS_JSON_FILE}.tmp"
  mv "${VERSIONS_JSON_FILE}.tmp" "${VERSIONS_JSON_FILE}"
}

function update_hash_in_file {
  local new_hash=$1
  
  sed -i '' "/sha256-map = {/,/};/ s/aarch64-darwin = \"[^\"]*\";/aarch64-darwin = \"${new_hash}\";/" "${AGPOD_NIX_FILE}"
}

function main {
  if [ $# -ne 1 ]; then
    usage
  fi
  
  local new_version=$1
  local current_version
  current_version=$(get_current_version)
  
  cmn_echo_info "Current version: ${current_version}"
  cmn_echo_info "New version: ${new_version}"
  
  if [ "${current_version}" = "${new_version}" ]; then
    cmn_die "Version ${new_version} is already set in ${VERSIONS_JSON_FILE}"
  fi
  
  cmn_echo_info "Fetching release info for v${new_version}..."
  local release_info
  release_info=$(fetch_release_info "${new_version}")
  
  if [ -z "${release_info}" ]; then
    cmn_die "Failed to fetch release info for v${new_version}"
  fi
  
  local download_url
  download_url=$(extract_download_url "${release_info}")
  
  if [ -z "${download_url}" ]; then
    cmn_die "Failed to extract download URL from release info"
  fi
  
  cmn_echo_info "Downloading and computing hash for ${download_url}..."
  local sha256
  sha256=$(fetch_and_compute_hash "${download_url}")
  
  if [ -z "${sha256}" ]; then
    cmn_die "Failed to compute SHA256 hash"
  fi
  
  cmn_echo_info "Found SHA256: ${sha256}"
  cmn_ask_to_continue "Update ${VERSIONS_JSON_FILE} and ${AGPOD_NIX_FILE}?"
  
  update_version_in_json "${new_version}"
  update_hash_in_file "${sha256}"
  
  cmn_echo_info "Successfully updated agpod"
  cmn_echo_info "Version: ${current_version} -> ${new_version}"
  cmn_echo_info "SHA256: ${sha256}"
}

main "$@"
