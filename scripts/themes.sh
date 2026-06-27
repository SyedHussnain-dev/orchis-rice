#!/usr/bin/env bash
# themes.sh — Install Orchis Dark GTK theme

set -Eeuo pipefail

# shellcheck source=utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

ORCHIS_REPO="https://github.com/vinceliuice/Orchis-theme.git"

install_theme() {
    header "Installing Orchis Dark Theme"

    # Check if already installed
    if [[ -d "${HOME}/.themes/Orchis-Dark" ]]; then
        info "Orchis-Dark theme already installed"
        success "Orchis Dark theme ready"
        return 0
    fi

    setup_temp
    local clone_dir="${TEMP_DIR}/Orchis-theme"

    info "Cloning Orchis theme repository..."
    git clone --depth 1 "$ORCHIS_REPO" "$clone_dir" 2>/dev/null || {
        error "Failed to clone Orchis theme repository"
        error "Check your internet connection and try again"
        return 1
    }

    info "Installing Orchis Dark..."
    cd "$clone_dir"
    bash ./install.sh -t default -c dark --tweaks macos 2>/dev/null || {
        error "Orchis theme installation script failed"
        error "Try installing manually: https://github.com/vinceliuice/Orchis-theme"
        cd "$ORCHIS_RICE_DIR"
        return 1
    }
    cd "$ORCHIS_RICE_DIR"

    success "Orchis Dark theme installed"
}

remove_theme() {
    info "Removing Orchis theme..."
    rm -rf "${HOME}/.themes/Orchis"*
    success "Orchis theme removed"
}
