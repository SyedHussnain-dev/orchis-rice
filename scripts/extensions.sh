#!/usr/bin/env bash
# extensions.sh — Install and enable GNOME Shell extensions

set -Eeuo pipefail

# shellcheck source=utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Extensions to install via gnome-extensions-cli (gext)
# Format: "uuid" "human-readable name"
GEXT_EXTENSIONS=(
    "blur-my-shell@auber"
    "dash-to-dock@micxgx.gmail.com"
    "arcmenu@arcmenu.com"
    "just-perfection-desktop@just-perfection"
    "clipboard-indicator@tudmotu.com"
    "caffeine@patapon.info"
    "tiling-assistant@leleat-on-github"
)

GEXT_NAMES=(
    "Blur My Shell"
    "Dash to Dock"
    "ArcMenu"
    "Just Perfection"
    "Clipboard Indicator"
    "Caffeine"
    "Tiling Assistant"
)

install_gext_cli() {
    # Install gnome-extensions-cli via pipx
    if command -v gext &>/dev/null; then
        return 0
    fi

    if ! command -v pipx &>/dev/null; then
        warn "pipx not found — cannot install gnome-extensions-cli"
        return 1
    fi

    info "Installing gnome-extensions-cli..."
    pipx install gnome-extensions-cli 2>/dev/null || {
        warn "Failed to install gnome-extensions-cli via pipx"
        return 1
    }

    # Add pipx bin to PATH for this session
    export PATH="${HOME}/.local/bin:${PATH}"

    if ! command -v gext &>/dev/null; then
        warn "gext command not found after installation"
        return 1
    fi
}

install_extension_via_gext() {
    local uuid="$1"
    local name="$2"

    gext install "$uuid" 2>/dev/null || {
        warn "Could not install ${name} automatically"
        warn "Install manually: https://extensions.gnome.org"
        return 1
    }

    # Enable the extension
    gnome-extensions enable "$uuid" 2>/dev/null || true
}

install_extensions() {
    header "Installing GNOME Extensions"

    # Install AppIndicator via apt (most reliable method)
    if dpkg -s gnome-shell-extension-appindicator &>/dev/null; then
        info "AppIndicator extension already installed"
    else
        info "Installing AppIndicator extension via apt..."
        sudo apt-get install -y -qq gnome-shell-extension-appindicator 2>/dev/null || {
            warn "Could not install AppIndicator via apt"
        }
    fi

    # Enable AppIndicator
    gnome-extensions enable "appindicatorsupport@rgcjonas.gmail.com" 2>/dev/null || true

    # Install gext CLI tool
    if ! install_gext_cli; then
        warn "Cannot install extensions automatically without gnome-extensions-cli"
        warn ""
        warn "To install extensions manually, visit https://extensions.gnome.org"
        warn "and install the following:"
        for name in "${GEXT_NAMES[@]}"; do
            warn "  • ${name}"
        done
        return 0
    fi

    # Install each extension
    local installed=0
    local failed=0

    for i in "${!GEXT_EXTENSIONS[@]}"; do
        local uuid="${GEXT_EXTENSIONS[$i]}"
        local name="${GEXT_NAMES[$i]}"

        info "Installing ${name}..."
        if install_extension_via_gext "$uuid" "$name"; then
            success "${name} installed"
            ((installed++))
        else
            ((failed++))
        fi
    done

    if [[ $failed -gt 0 ]]; then
        warn "${failed} extension(s) need manual installation"
        warn "Visit: https://extensions.gnome.org"
    fi

    success "Extensions setup complete (${installed} installed)"
}

remove_extensions() {
    info "Disabling installed extensions..."
    for uuid in "${GEXT_EXTENSIONS[@]}"; do
        gnome-extensions disable "$uuid" 2>/dev/null || true
    done
    gnome-extensions disable "appindicatorsupport@rgcjonas.gmail.com" 2>/dev/null || true
    success "Extensions disabled"
}
