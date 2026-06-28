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
CONFIG_FILE="${ORCHIS_RICE_DIR}/config/default.conf"
LOG_DIR="${HOME}/.orchis-rice"
LOG_FILE="${LOG_DIR}/install.log"

# ── Step Tracking ───────────────────────────────────────────────────────────
CURRENT_STEP=0
TOTAL_STEPS=8

# ── Installation Status Tracking ────────────────────────────────────────────
# Track what was installed, skipped, or failed for the final summary.
declare -gA INSTALL_STATUS=()
declare -ga EXTENSION_RESULTS=()

# ── Default Configuration Values ────────────────────────────────────────────
# These are used if config/default.conf is missing or incomplete.
GTK_THEME="${GTK_THEME:-Orchis-Dark}"
ICON_THEME="${ICON_THEME:-Tela-circle-dark}"
CURSOR_THEME="${CURSOR_THEME:-Bibata-Modern-Ice}"
CURSOR_SIZE="${CURSOR_SIZE:-24}"
FONT_NAME="${FONT_NAME:-Inter}"
FONT_STYLE="${FONT_STYLE:-Regular}"
FONT_SIZE="${FONT_SIZE:-11}"
MONOSPACE_FONT="${MONOSPACE_FONT:-JetBrainsMono Nerd Font}"
MONOSPACE_FONT_SIZE="${MONOSPACE_FONT_SIZE:-13}"
TITLEBAR_FONT_STYLE="${TITLEBAR_FONT_STYLE:-Bold}"
COLOR_SCHEME="${COLOR_SCHEME:-prefer-dark}"
CLOCK_FORMAT="${CLOCK_FORMAT:-24h}"
BUTTON_LAYOUT="${BUTTON_LAYOUT:-close,minimize,maximize:}"

# Orchis Theme Options Defaults
ORCHIS_THEME_VARIANT="${ORCHIS_THEME_VARIANT:-default}"
ORCHIS_COLOR_VARIANT="${ORCHIS_COLOR_VARIANT:-dark}"
ORCHIS_SIZE_VARIANT="${ORCHIS_SIZE_VARIANT:-}"
ORCHIS_ICON_VARIANT="${ORCHIS_ICON_VARIANT:-}"
ORCHIS_TWEAKS="${ORCHIS_TWEAKS:-macos}"
ORCHIS_ROUND="${ORCHIS_ROUND:-}"
ORCHIS_LIBADWAITA="${ORCHIS_LIBADWAITA:-false}"
ORCHIS_FIXED="${ORCHIS_FIXED:-false}"
ORCHIS_SHELL_VERSION="${ORCHIS_SHELL_VERSION:-}"

# ── Config Loading ──────────────────────────────────────────────────────────
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        info "Loading configuration from config/default.conf"
        # Source config — variables set there override the defaults above
        # shellcheck source=/dev/null
        source "$CONFIG_FILE"
    else
        info "No config/default.conf found — using defaults"
    fi
}

# ── Logging Setup ───────────────────────────────────────────────────────────
setup_logging() {
    mkdir -p "$LOG_DIR"
    # Write header to log file
    {
        printf "=%.0s" {1..60}
        printf "\n"
        printf "Orchis Rice Installation Log\n"
        printf "Date: %s\n" "$(date '+%Y-%m-%d %H:%M:%S')"
        printf "=%.0s" {1..60}
        printf "\n\n"
    } > "$LOG_FILE"
}

# Log a message to the log file (in addition to stdout)
log() {
    if [[ -n "${LOG_FILE:-}" ]] && [[ -d "${LOG_DIR:-}" ]]; then
        printf "%s %s\n" "$(date '+%H:%M:%S')" "$*" >> "$LOG_FILE" 2>/dev/null || true
    fi
}

# ── Logging ─────────────────────────────────────────────────────────────────
info() {
    printf "${BLUE}  ▸${RESET} %s\n" "$*"
    log "[INFO] $*"
}

success() {
    printf "${GREEN}  ✓${RESET} %s\n" "$*"
    log "[OK]   $*"
}

warn() {
    printf "${YELLOW}  ⚠${RESET} %s\n" "$*" >&2
    log "[WARN] $*"
}

error() {
    printf "${RED}  ✗${RESET} %s\n" "$*" >&2
    log "[ERR]  $*"
}

header() {
    if [[ $CURRENT_STEP -lt $TOTAL_STEPS ]]; then
        CURRENT_STEP=$((CURRENT_STEP + 1))
        printf "\n${BOLD}${MAGENTA}  [%d/%d] %s${RESET}\n" "$CURRENT_STEP" "$TOTAL_STEPS" "$*"
    else
        printf "\n${BOLD}${MAGENTA}  %s${RESET}\n" "$*"
    fi
    log "[STEP] $*"
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
        return 0
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

# ── OS Version Detection ───────────────────────────────────────────────
check_os() {
    if [[ ! -f /etc/os-release ]]; then
        warn "Cannot detect OS — /etc/os-release not found"
        return 1
    fi

    # shellcheck source=/dev/null
    source /etc/os-release

    local version="${VERSION_ID:-0}"

    if [[ "${ID:-}" == "ubuntu" ]]; then
        export OS_TYPE="ubuntu"
        export PACKAGE_MANAGER="apt"
        
        # Fully supported versions — no warnings
        if [[ "$version" == "24.04" ]] || [[ "$version" == "24.10" ]]; then
            info "Detected Ubuntu ${version} — fully supported"
            return 0
        fi

        # Newer than 24.04 — informational notice, continue
        if awk "BEGIN {exit !($version > 24.04)}"; then
            info "Detected Ubuntu ${version}"
            info "Proceeding... Some settings may differ on this version."
            return 0
        fi

        # Older or unrecognized — warn but continue
        warn "Designed for Ubuntu 24.04+ (detected: ${version})"
        warn "Proceeding anyway — some features may not work"
        return 0

    elif [[ "${ID:-}" == "fedora" ]]; then
        export OS_TYPE="fedora"
        export PACKAGE_MANAGER="dnf"
        
        # Fully supported versions — no warnings
        if [[ "$version" == "40" ]] || [[ "$version" == "41" ]]; then
            info "Detected Fedora ${version} — fully supported"
            return 0
        fi

        if awk "BEGIN {exit !($version > 41)}"; then
            info "Detected Fedora ${version}"
            info "Proceeding... Some settings may differ on this version."
            return 0
        fi

        warn "Designed for Fedora 40+ (detected: ${version})"
        warn "Proceeding anyway — some features may not work"
        return 0

    else
        warn "This script is designed for Ubuntu and Fedora (detected: ${ID:-unknown})"
        return 1
    fi
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

# ── Nerd Font Detection ────────────────────────────────────────────────────
# Detect installed JetBrainsMono Nerd Font family name via fc-list.
# Returns the detected family name, or empty string if not found.
detect_nerd_font() {
    local -a candidates=(
        "JetBrainsMono Nerd Font"
        "JetBrainsMono Nerd Font Mono"
        "JetBrainsMonoNL Nerd Font"
        "JetBrainsMonoNL Nerd Font Mono"
        "JetBrainsMono NF"
        "JetBrainsMono NFM"
    )

    if ! command -v fc-list &>/dev/null; then
        return 1
    fi

    local fc_output
    fc_output=$(fc-list --format="%{family}\n" 2>/dev/null | sort -u)

    for candidate in "${candidates[@]}"; do
        if echo "$fc_output" | grep -qF "$candidate"; then
            printf "%s" "$candidate"
            return 0
        fi
    done

    return 1
}

# ── Format Time ─────────────────────────────────────────────────────────────
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
