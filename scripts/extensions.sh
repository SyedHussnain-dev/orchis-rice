#!/usr/bin/env bash
# extensions.sh — Install and enable GNOME Shell extensions

set -Eeuo pipefail

# shellcheck source=utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Extensions to install via gnome-extensions-cli (gext)
# Format: "uuid" paired with its display name in GEXT_NAMES
GEXT_EXTENSIONS=(
    "blur-my-shell@auber.me"
    "dash-to-dock@micxgx.gmail.com"
    "arcmenu@arcmenu.com"
    "just-perfection-desktop@just-perfection"
    "Vitals@CoreCoding.com"
    "clipboard-indicator@tudmotu.com"
    "caffeine@patapon.info"
)

GEXT_NAMES=(
    "Blur My Shell"
    "Dash to Dock"
    "ArcMenu"
    "Just Perfection"
    "Vitals"
    "Clipboard Indicator"
    "Caffeine"
)

# ── Extension Manager Detection ─────────────────────────────────────────────
# Check if the Extension Manager GUI app is available
has_extension_manager() {
    if command -v extension-manager &>/dev/null; then
        return 0
    fi
    if dpkg -s gnome-shell-extension-manager &>/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# ── Rich Fallback Guide ─────────────────────────────────────────────────────
# Display a helpful recovery guide when automatic installation fails
print_extension_fallback_guide() {
    local -a failed_names=("$@")

    printf "\n"
    printf "${BOLD}${YELLOW}  ──────────────────────────────────────────────────${RESET}\n"
    printf "\n"
    printf "${BOLD}${YELLOW}  ⚠  Some extensions need manual installation.${RESET}\n"
    printf "\n"

    if has_extension_manager; then
        printf "  ${BOLD}Open Extension Manager${RESET} (already installed) and search for:\n"
    else
        printf "  Install ${BOLD}Extension Manager${RESET} from Ubuntu Software, then search for:\n"
        printf "  ${DIM}  Or visit: https://extensions.gnome.org${RESET}\n"
    fi

    printf "\n"
    for name in "${failed_names[@]}"; do
        printf "    ${CYAN}•${RESET} %s\n" "$name"
    done
    printf "\n"
    printf "  After installing, ${BOLD}log out and log back in${RESET} to activate them.\n"
    printf "  ${DIM}(Wayland: log out required. X11: Alt+F2 → r → Enter)${RESET}\n"
    printf "\n"
    printf "  ${DIM}Note: GNOME extension settings only apply after restart.${RESET}\n"
    printf "${BOLD}${YELLOW}  ──────────────────────────────────────────────────${RESET}\n"
    printf "\n"
}

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
    local gext_available=true
    if ! install_gext_cli; then
        gext_available=false
        warn "Cannot install extensions automatically without gnome-extensions-cli"
    fi

    # Install each extension
    local installed=0
    local failed=0
    local -a failed_names=()

    for i in "${!GEXT_EXTENSIONS[@]}"; do
        local uuid="${GEXT_EXTENSIONS[$i]}"
        local name="${GEXT_NAMES[$i]}"

        if [[ "$gext_available" == true ]]; then
            info "Installing ${name}..."
            if install_extension_via_gext "$uuid" "$name"; then
                success "${name} installed"
                ((installed++))
                EXTENSION_RESULTS+=("✓ ${name}")
            else
                ((failed++))
                failed_names+=("$name")
                EXTENSION_RESULTS+=("⚠ ${name} (manual install required)")
            fi
        else
            ((failed++))
            failed_names+=("$name")
            EXTENSION_RESULTS+=("⚠ ${name} (manual install required)")
        fi
    done

    # Show fallback guide if any extensions failed
    if [[ $failed -gt 0 ]]; then
        print_extension_fallback_guide "${failed_names[@]}"
        INSTALL_STATUS[extensions]="partial"
    else
        INSTALL_STATUS[extensions]="installed"
    fi

    success "Extensions setup complete (${installed} installed, ${failed} need manual installation)"
}

remove_extensions() {
    info "Disabling installed extensions..."
    for uuid in "${GEXT_EXTENSIONS[@]}"; do
        gnome-extensions disable "$uuid" 2>/dev/null || true
    done
    gnome-extensions disable "appindicatorsupport@rgcjonas.gmail.com" 2>/dev/null || true
    success "Extensions disabled"
}
