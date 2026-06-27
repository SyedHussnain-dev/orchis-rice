#!/usr/bin/env bash
# fonts.sh — Install Inter and JetBrains Mono Nerd Font

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

INTER_URL="https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip"
JETBRAINS_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip"

FONTS_DIR="${HOME}/.local/share/fonts"

install_fonts() {
    header "Installing Fonts"

    mkdir -p "$FONTS_DIR"
    setup_temp

    # ── Inter ───────────────────────────────────────────────────────────────
    if ls "${FONTS_DIR}"/Inter*.ttf &>/dev/null || ls "${FONTS_DIR}"/Inter/*.ttf &>/dev/null; then
        info "Inter font already installed"
    else
        info "Downloading Inter font..."
        local inter_zip="${TEMP_DIR}/Inter.zip"
        download "$INTER_URL" "$inter_zip" || {
            warn "Failed to download Inter font — skipping"
        }

        if [[ -f "$inter_zip" ]]; then
            info "Installing Inter font..."
            local inter_dir="${TEMP_DIR}/Inter"
            mkdir -p "$inter_dir"
            unzip -qo "$inter_zip" -d "$inter_dir"

            # Install variable and static fonts
            find "$inter_dir" -name "*.ttf" -exec cp {} "$FONTS_DIR/" \;
            success "Inter font installed"
        fi
    fi

    # ── JetBrains Mono Nerd Font ────────────────────────────────────────────
    if ls "${FONTS_DIR}"/JetBrainsMonoNerd*.ttf &>/dev/null; then
        info "JetBrains Mono Nerd Font already installed"
    else
        info "Downloading JetBrains Mono Nerd Font..."
        local jb_zip="${TEMP_DIR}/JetBrainsMono.zip"
        download "$JETBRAINS_URL" "$jb_zip" || {
            warn "Failed to download JetBrains Mono Nerd Font — skipping"
        }

        if [[ -f "$jb_zip" ]]; then
            info "Installing JetBrains Mono Nerd Font..."
            unzip -qo "$jb_zip" -d "$FONTS_DIR/" '*.ttf'
            success "JetBrains Mono Nerd Font installed"
        fi
    fi

    # Rebuild font cache
    info "Rebuilding font cache..."
    fc-cache -f "$FONTS_DIR" 2>/dev/null || true

    success "Fonts installed"
}

remove_fonts() {
    info "Removing installed fonts..."
    rm -f "${FONTS_DIR}"/Inter*.ttf
    rm -f "${FONTS_DIR}"/JetBrainsMonoNerd*.ttf
    fc-cache -f 2>/dev/null || true
    success "Fonts removed"
}
