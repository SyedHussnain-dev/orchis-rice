#!/usr/bin/env bash
# dependencies.sh — Install system dependencies for Orchis Rice

set -Eeuo pipefail

# shellcheck source=utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Packages required by the installer and themes
UBUNTU_PACKAGES=(
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
    dconf-cli
)

FEDORA_PACKAGES=(
    git
    curl
    wget
    unzip
    tar
    xz
    gnome-tweaks
    gnome-shell-extensions
    extension-manager
    sassc
    glib2-devel
    gtk-murrine-engine
    pipx
    dconf
)

# Set the active package list based on OS
if [[ "${OS_TYPE:-}" == "fedora" ]]; then
    PACKAGES=("${FEDORA_PACKAGES[@]}")
else
    PACKAGES=("${UBUNTU_PACKAGES[@]}")
fi

# Check which packages are already installed
get_missing_packages() {
    local -a missing=()
    for pkg in "${PACKAGES[@]}"; do
        if [[ "${PACKAGE_MANAGER:-apt}" == "apt" ]]; then
            if ! dpkg -s "$pkg" &>/dev/null; then
                missing+=("$pkg")
            fi
        elif [[ "${PACKAGE_MANAGER:-apt}" == "dnf" ]]; then
            if ! rpm -q "$pkg" &>/dev/null; then
                missing+=("$pkg")
            fi
        fi
    done
    printf '%s\n' "${missing[@]+${missing[@]}}"
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
    if [[ "${PACKAGE_MANAGER:-apt}" == "apt" ]]; then
        sudo apt-get update -qq || {
            error "Failed to update package lists"
            return 1
        }
    fi
    # dnf usually updates repos automatically when needed

    info "Installing missing packages..."
    if [[ "${PACKAGE_MANAGER:-apt}" == "apt" ]]; then
        # shellcheck disable=SC2086
        sudo apt-get install -y -qq $missing || {
            error "Failed to install some packages"
            error "Try running: sudo apt-get install -y ${PACKAGES[*]}"
            return 1
        }
    elif [[ "${PACKAGE_MANAGER:-apt}" == "dnf" ]]; then
        # shellcheck disable=SC2086
        sudo dnf install -y -q $missing || {
            error "Failed to install some packages"
            error "Try running: sudo dnf install -y ${PACKAGES[*]}"
            return 1
        }
    fi

    # Ensure pipx path is set up for this session
    if command -v pipx &>/dev/null; then
        pipx ensurepath &>/dev/null 2>&1 || true
        export PATH="${HOME}/.local/bin:${PATH}"
    fi

    success "Dependencies installed"
}
