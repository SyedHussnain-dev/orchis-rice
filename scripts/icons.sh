#!/usr/bin/env bash
# icons.sh — Install Tela Circle Dark icon theme

set -Eeuo pipefail

# shellcheck source=utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

TELA_REPO="https://github.com/vinceliuice/Tela-circle-icon-theme.git"
ICONS_BASE_DIR="${HOME}/.local/share/icons"

install_icons() {
    header "Installing Tela Circle Icons"

    # Check if already installed
    if [[ -d "${ICONS_BASE_DIR}/Tela-circle-dark" ]]; then
        info "Tela Circle Dark icons already installed"
        success "Tela Circle Dark icons ready"
        return 0
    fi

    setup_temp
    local clone_dir="${TEMP_DIR}/Tela-circle-icon-theme"

    info "Cloning Tela Circle icon repository..."
    git clone --depth 1 "$TELA_REPO" "$clone_dir" 2>/dev/null || {
        error "Failed to clone Tela Circle icon repository"
        error "Check your internet connection and try again"
        return 1
    }

    info "Installing Tela Circle Dark icons (standard + dark variants only)..."
    cd "$clone_dir"
    # Install only the standard set — this creates Tela-circle, Tela-circle-dark,
    # and Tela-circle-light without all the accent-color variants (saves time and space)
    if bash ./install.sh -d "$ICONS_BASE_DIR" 2>/dev/null; then
        success "Tela Circle Dark icons installed"
    else
        error "Tela Circle icon installation failed"
        error "Try installing manually: https://github.com/vinceliuice/Tela-circle-icon-theme"
        cd "$ORCHIS_RICE_DIR"
        return 1
    fi
    cd "$ORCHIS_RICE_DIR"

    # Verify the expected theme directory exists
    if [[ ! -d "${ICONS_BASE_DIR}/Tela-circle-dark" ]]; then
        warn "Tela-circle-dark directory not found after installation"
        warn "Icon theme may still work — check ~/.local/share/icons/"
    fi
}

remove_icons() {
    info "Removing Tela Circle icons..."
    rm -rf "${ICONS_BASE_DIR}/Tela-circle"*
    success "Tela Circle icons removed"
}
