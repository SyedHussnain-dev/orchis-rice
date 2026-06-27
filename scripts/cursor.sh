#!/usr/bin/env bash
# cursor.sh — Install Bibata Modern Ice cursor theme

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

BIBATA_VERSION="v2.0.7"
BIBATA_URL="https://github.com/ful1e5/Bibata_Cursor/releases/download/${BIBATA_VERSION}/Bibata-Modern-Ice.tar.xz"
CURSOR_NAME="Bibata-Modern-Ice"

install_cursor() {
    header "Installing Bibata Modern Ice Cursor"

    local icons_dir="${HOME}/.local/share/icons"

    # Check if already installed
    if [[ -d "${icons_dir}/${CURSOR_NAME}" ]]; then
        info "Bibata Modern Ice cursor already installed"
        success "Bibata Modern Ice cursor ready"
        return 0
    fi

    setup_temp
    mkdir -p "$icons_dir"

    local archive="${TEMP_DIR}/${CURSOR_NAME}.tar.xz"

    info "Downloading Bibata Modern Ice cursor (${BIBATA_VERSION})..."
    download "$BIBATA_URL" "$archive" || {
        error "Failed to download Bibata cursor"
        error "Try downloading manually from: https://github.com/ful1e5/Bibata_Cursor/releases"
        return 1
    }

    info "Extracting cursor theme..."
    tar -xf "$archive" -C "$icons_dir" || {
        error "Failed to extract cursor archive"
        return 1
    }

    success "Bibata Modern Ice cursor installed"
}

remove_cursor() {
    info "Removing Bibata cursor..."
    rm -rf "${HOME}/.local/share/icons/${CURSOR_NAME}"
    success "Bibata cursor removed"
}
