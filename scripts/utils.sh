#!/usr/bin/env bash
# shellcheck disable=SC2034
# utils.sh — Shared utilities for Orchis Rice installer
# Colors, logging, helpers used by all other scripts.

set -Eeuo pipefail

# ── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Paths ───────────────────────────────────────────────────────────────────
ORCHIS_RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="${ORCHIS_RICE_DIR}/.orchis-tmp"

# ── Step Tracking ───────────────────────────────────────────────────────────
CURRENT_STEP=0
TOTAL_STEPS=8

# ── Logging ─────────────────────────────────────────────────────────────────
info() {
    printf "${BLUE}  ▸${RESET} %s\n" "$*"
}

success() {
    printf "${GREEN}  ✓${RESET} %s\n" "$*"
}

warn() {
    printf "${YELLOW}  ⚠${RESET} %s\n" "$*" >&2
}

error() {
    printf "${RED}  ✗${RESET} %s\n" "$*" >&2
}

header() {
    if [[ $CURRENT_STEP -lt $TOTAL_STEPS ]]; then
        CURRENT_STEP=$((CURRENT_STEP + 1))
        printf "\n${BOLD}${MAGENTA}  [%d/%d] %s${RESET}\n" "$CURRENT_STEP" "$TOTAL_STEPS" "$*"
    else
        printf "\n${BOLD}${MAGENTA}  %s${RESET}\n" "$*"
    fi
}

# ── Spinner ─────────────────────────────────────────────────────────────────
# Usage: long_command & spin $! "Installing thing"
spin() {
    local pid=$1
    local msg="${2:-Working}"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r${CYAN}  %s${RESET} %s" "${frames[$i]}" "$msg"
        i=$(( (i + 1) % ${#frames[@]} ))
        sleep 0.1
    done

    wait "$pid"
    local exit_code=$?
    printf "\r\033[K"
    return $exit_code
}

# ── Helpers ─────────────────────────────────────────────────────────────────

# Check if a command exists
require_command() {
    if ! command -v "$1" &>/dev/null; then
        error "Required command not found: $1"
        return 1
    fi
}

# Safe gsettings wrapper — warns instead of crashing if schema is missing
safe_gsettings() {
    local action="$1"
    shift

    if ! gsettings "$action" "$@" 2>/dev/null; then
        warn "gsettings: could not $action $*"
        return 1
    fi
}

# Check if a gsettings schema exists
schema_exists() {
    gsettings list-keys "$1" &>/dev/null 2>&1
}

# Create and manage temp directory
setup_temp() {
    mkdir -p "$TEMP_DIR"
}

cleanup_temp() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Download a file with progress
download() {
    local url="$1"
    local dest="$2"
    local desc="${3:-Downloading}"

    if command -v wget &>/dev/null; then
        wget -q --show-progress -O "$dest" "$url" 2>&1 || {
            error "Failed to download: $url"
            return 1
        }
    elif command -v curl &>/dev/null; then
        curl -fSL --progress-bar -o "$dest" "$url" || {
            error "Failed to download: $url"
            return 1
        }
    else
        error "Neither wget nor curl found"
        return 1
    fi
}

# Check Ubuntu version
check_ubuntu() {
    if [[ ! -f /etc/os-release ]]; then
        warn "Cannot detect OS — /etc/os-release not found"
        return 1
    fi

    # shellcheck source=/dev/null
    source /etc/os-release

    if [[ "${ID:-}" != "ubuntu" ]]; then
        warn "This script is designed for Ubuntu (detected: ${ID:-unknown})"
        return 1
    fi

    if [[ "${VERSION_ID:-}" != "24.04" ]]; then
        warn "Designed for Ubuntu 24.04 (detected: ${VERSION_ID:-unknown})"
        warn "Proceeding anyway — some features may not work"
    fi

    return 0
}

# Check GNOME version
check_gnome() {
    if ! command -v gnome-shell &>/dev/null; then
        warn "GNOME Shell not found"
        return 1
    fi

    local gnome_version
    gnome_version=$(gnome-shell --version 2>/dev/null | grep -oP '\d+' | head -1)

    if [[ "${gnome_version:-0}" -lt 45 ]]; then
        warn "GNOME ${gnome_version:-unknown} detected — designed for GNOME 46"
        warn "Proceeding anyway — some extensions may not work"
    fi

    return 0
}

# Format elapsed time
format_time() {
    local seconds=$1
    local minutes=$((seconds / 60))
    local remaining=$((seconds % 60))

    if [[ $minutes -gt 0 ]]; then
        printf "%dm %ds" "$minutes" "$remaining"
    else
        printf "%ds" "$remaining"
    fi
}
