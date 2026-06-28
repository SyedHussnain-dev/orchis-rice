#!/usr/bin/env bash
# fonts.sh — Install Inter and JetBrains Mono Nerd Font

set -Eeuo pipefail

# shellcheck source=utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

INTER_URL="https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip"
JETBRAINS_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip"

FONTS_DIR="${HOME}/.local/share/fonts"

_inter_installed() {
    ls "${FONTS_DIR}"/Inter*.ttf &>/dev/null 2>&1 || \
    ls "${FONTS_DIR}"/Inter/*.ttf &>/dev/null 2>&1
}

_jetbrains_installed() {
    ls "${FONTS_DIR}"/JetBrainsMonoNerd*.ttf &>/dev/null 2>&1
}

install_fonts() {
    header "Installing Fonts"

    mkdir -p "$FONTS_DIR"
    setup_temp

    local inter_ok=false
    local jb_ok=false

    # ── Inter ───────────────────────────────────────────────────────────────
    if _inter_installed; then
        info "Inter font already installed"
        inter_ok=true
    else
        info "Downloading Inter font..."
        local inter_zip="${TEMP_DIR}/Inter.zip"
        if download "$INTER_URL" "$inter_zip"; then
            info "Installing Inter font..."
            local inter_dir="${TEMP_DIR}/Inter"
            mkdir -p "$inter_dir"
            unzip -qo "$inter_zip" -d "$inter_dir"
            # Install only desktop-relevant TTFs (skip web/variable fonts)
            find "$inter_dir" -name "*.ttf" -not -path "*/web/*" -exec cp {} "$FONTS_DIR/" \;
            inter_ok=true
        else
            warn "Failed to download Inter font — skipping"
        fi
    fi

    # ── JetBrains Mono Nerd Font ────────────────────────────────────────────
    if _jetbrains_installed; then
        info "JetBrains Mono Nerd Font already installed"
        jb_ok=true
    else
        info "Downloading JetBrains Mono Nerd Font..."
        local jb_zip="${TEMP_DIR}/JetBrainsMono.zip"
        if download "$JETBRAINS_URL" "$jb_zip"; then
            info "Installing JetBrains Mono Nerd Font..."
            unzip -qo "$jb_zip" -d "$FONTS_DIR/" '*.ttf'
            jb_ok=true
        else
            warn "Failed to download JetBrains Mono Nerd Font — skipping"
        fi
    fi

    # ── Rebuild Font Cache ──────────────────────────────────────────────────
    info "Rebuilding font cache..."
    fc-cache -f "$FONTS_DIR" 2>/dev/null || true

    # ── Verification ────────────────────────────────────────────────────────
    local verified=true

    if [[ "$inter_ok" == true ]]; then
        if fc-list | grep -qi "Inter" &>/dev/null; then
            success "Inter font verified"
        else
            warn "Inter font files installed but not detected by fc-list yet"
            warn "This usually resolves after logging out and back in"
            verified=false
        fi
    fi

    if [[ "$jb_ok" == true ]]; then
        if fc-list | grep -qi "JetBrainsMono" &>/dev/null; then
            success "JetBrains Mono Nerd Font verified"
        else
            warn "JetBrains Mono files installed but not detected by fc-list yet"
            verified=false
        fi
    fi

    # ── Final Status ────────────────────────────────────────────────────────
    if [[ "$inter_ok" == true ]] && [[ "$jb_ok" == true ]] && [[ "$verified" == true ]]; then
        success "Fonts installed and verified"
        INSTALL_STATUS[fonts]="installed"
    elif [[ "$inter_ok" == true ]] || [[ "$jb_ok" == true ]]; then
        warn "Some fonts may need a session restart to appear in fc-list"
        warn "Check: fc-list | grep -i 'inter\|jetbrains'"
        INSTALL_STATUS[fonts]="partial"
    else
        warn "Font installation failed — install manually to ~/.local/share/fonts/"
        INSTALL_STATUS[fonts]="failed"
    fi
}

remove_fonts() {
    info "Removing installed fonts..."
    rm -f "${FONTS_DIR}"/Inter*.ttf
    rm -rf "${FONTS_DIR}"/Inter/
    rm -f "${FONTS_DIR}"/JetBrainsMonoNerd*.ttf
    fc-cache -f 2>/dev/null || true
    success "Fonts removed"
}
