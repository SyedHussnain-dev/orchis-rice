#!/usr/bin/env bash
# icons.sh — Install Tela Circle Dark icon theme

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

TELA_REPO="https://github.com/vinceliuice/Tela-circle-icon-theme.git"

install_icons() {
    header "Installing Tela Circle Icons"

    # Check if already installed
    if [[ -d "${HOME}/.local/share/icons/Tela-circle-dark" ]]; then
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

    info "Installing Tela Circle Dark icons..."
    cd "$clone_dir"
    bash ./install.sh -d "${HOME}/.local/share/icons" 2>/dev/null || {
        error "Tela Circle icon installation failed"
        error "Try installing manually: https://github.com/vinceliuice/Tela-circle-icon-theme"
        cd "$ORCHIS_RICE_DIR"
        return 1
    }
    cd "$ORCHIS_RICE_DIR"

    success "Tela Circle Dark icons installed"
}

remove_icons() {
    info "Removing Tela Circle icons..."
    rm -rf "${HOME}/.local/share/icons/Tela-circle"*
    success "Tela Circle icons removed"
}
