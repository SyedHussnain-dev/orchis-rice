#!/usr/bin/env bash
# dependencies.sh — Install system dependencies for Orchis Rice

set -Eeuo pipefail

# shellcheck source=utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Packages required by the installer and themes
PACKAGES=(
    git
    curl
    wget
    unzip
    tar
    xz-utils
    gnome-tweaks
    gnome-shell-extensions
    gnome-shell-extension-manager
    sassc
    libglib2.0-dev-bin
    gtk2-engines-murrine
    pipx
)

# Check which packages are already installed
get_missing_packages() {
    local missing=()
    for pkg in "${PACKAGES[@]}"; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done
    printf '%s\n' "${missing[@]}"
}

install_dependencies() {
    header "Installing Dependencies"

    local missing
    missing=$(get_missing_packages)

    if [[ -z "$missing" ]]; then
        success "All dependencies already installed"
        return 0
    fi

    info "Updating package lists..."
    sudo apt-get update -qq || {
        error "Failed to update package lists"
        return 1
    }

    info "Installing missing packages..."
    # shellcheck disable=SC2086
    sudo apt-get install -y -qq $missing || {
        error "Failed to install some packages"
        error "Try running: sudo apt-get install -y ${PACKAGES[*]}"
        return 1
    }

    # Ensure pipx path is set up
    if command -v pipx &>/dev/null; then
        pipx ensurepath &>/dev/null 2>&1 || true
    fi

    success "Dependencies installed"
}
