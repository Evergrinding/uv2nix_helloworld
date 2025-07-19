#!/usr/bin/env bash
# A script to synchronize a project's nixpkgs flake input with a
# specific NixOS configuration flake on disk.

set -euo pipefail

# --- Argument Parsing ---
if [[ $# -ne 1 ]]; then
  echo "Error: Incorrect number of arguments." >&2
  echo "Usage: $0 /path/to/nixos_config" >&2
  exit 1
fi

SYSTEM_CONFIG_DIR="$1"

# --- Validation ---
if [[ ! -d "$SYSTEM_CONFIG_DIR" || ! -f "$SYSTEM_CONFIG_DIR/flake.lock" ]]; then
  echo "Error: System config directory '$SYSTEM_CONFIG_DIR' does not contain a flake.lock file." >&2
  exit 1
fi

# --- Prerequisite Checks ---
for cmd in nix jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: Command '$cmd' not found. Please ensure it is installed and in your PATH." >&2
    exit 1
  fi
done

# --- Helper Functions ---
reconstruct_flake_url() {
  local json_data="$1"
  local type
  type=$(echo "$json_data" | jq -r '.type')

  if [[ "$type" == "github" ]]; then
    echo "$json_data" | jq -r '"github:\(.owner)/\(.repo)/\(.rev)"'
  else
    echo "Error: Unsupported flake input type '$type' in system's nixpkgs." >&2
    return 1
  fi
}

# --- Main Logic ---
echo "--- Step 1: Extracting nixpkgs pin from the config's flake.lock ---"

# This is the key change: we directly ask nix to show us the metadata
# for the user-provided config directory. This reads its flake.lock.
SYSTEM_NIXPKGS_LOCKED_JSON=$(nix flake metadata --json "path:$SYSTEM_CONFIG_DIR" | jq '.locks.nodes.nixpkgs.locked')

if [[ -z "$SYSTEM_NIXPKGS_LOCKED_JSON" || "$SYSTEM_NIXPKGS_LOCKED_JSON" == "null" ]]; then
    echo "Error: Could not find 'nixpkgs' input in '$SYSTEM_CONFIG_DIR/flake.lock'." >&2
    exit 1
fi

echo "Found system's locked nixpkgs data."
SYSTEM_NIXPKGS_LOCKED_URL=$(reconstruct_flake_url "$SYSTEM_NIXPKGS_LOCKED_JSON")
echo "Reconstructed system nixpkgs URL: $SYSTEM_NIXPKGS_LOCKED_URL"
echo ""

echo "--- Step 2: Applying the pin to the project ---"
nix flake update nixpkgs \
  --override-input nixpkgs "$SYSTEM_NIXPKGS_LOCKED_URL"

echo ""
echo "✅ Success: Project has its nixpkgs input synchronized with the config at '$SYSTEM_CONFIG_DIR'."