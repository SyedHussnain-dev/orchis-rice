#!/usr/bin/env bash
# gnome.sh — Apply GNOME desktop configuration via gsettings

set -Eeuo pipefail

# shellcheck source=utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

apply_gnome_settings() {
    header "Applying GNOME Configuration"

    # ── Appearance ──────────────────────────────────────────────────────────
    info "Setting dark mode..."
    safe_gsettings set org.gnome.desktop.interface color-scheme "${COLOR_SCHEME}"
    safe_gsettings set org.gnome.desktop.interface gtk-theme "${GTK_THEME}"
    safe_gsettings set org.gnome.desktop.interface icon-theme "${ICON_THEME}"
    safe_gsettings set org.gnome.desktop.interface cursor-theme "${CURSOR_THEME}"
    safe_gsettings set org.gnome.desktop.interface cursor-size "${CURSOR_SIZE}"

    # ── Fonts ───────────────────────────────────────────────────────────────
    info "Setting fonts..."
    safe_gsettings set org.gnome.desktop.interface font-name "${FONT_NAME} ${FONT_STYLE} ${FONT_SIZE}"
    safe_gsettings set org.gnome.desktop.interface document-font-name "${FONT_NAME} ${FONT_STYLE} ${FONT_SIZE}"
    safe_gsettings set org.gnome.desktop.wm.preferences titlebar-font "${FONT_NAME} ${TITLEBAR_FONT_STYLE} ${FONT_SIZE}"

    # ── Monospace Font (detect via fc-list) ──────────────────────────────────
    local detected_mono=""
    detected_mono=$(detect_nerd_font) || true

    if [[ -n "$detected_mono" ]]; then
        info "Detected monospace font: ${detected_mono}"
        safe_gsettings set org.gnome.desktop.interface monospace-font-name "${detected_mono} ${MONOSPACE_FONT_SIZE}"
    else
        warn "JetBrainsMono Nerd Font not detected via fc-list"
        warn "Trying configured value: ${MONOSPACE_FONT} ${MONOSPACE_FONT_SIZE}"
        safe_gsettings set org.gnome.desktop.interface monospace-font-name "${MONOSPACE_FONT} ${MONOSPACE_FONT_SIZE}"
    fi

    # ── Font rendering ──────────────────────────────────────────────────────
    safe_gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
    safe_gsettings set org.gnome.desktop.interface font-hinting 'slight'

    # ── Window management ───────────────────────────────────────────────────
    info "Configuring window behavior..."
    safe_gsettings set org.gnome.desktop.wm.preferences button-layout "${BUTTON_LAYOUT}"
    safe_gsettings set org.gnome.mutter center-new-windows true
    safe_gsettings set org.gnome.mutter edge-tiling true
    # Focus windows when they demand attention without stealing focus
    safe_gsettings set org.gnome.desktop.wm.preferences focus-new-windows 'smart'
    safe_gsettings set org.gnome.desktop.wm.preferences num-workspaces 4

    # ── Clock ───────────────────────────────────────────────────────────────
    info "Configuring clock..."
    safe_gsettings set org.gnome.desktop.interface clock-show-weekday true
    safe_gsettings set org.gnome.desktop.interface clock-show-date true
    safe_gsettings set org.gnome.desktop.interface clock-show-seconds false
    safe_gsettings set org.gnome.desktop.interface clock-format "${CLOCK_FORMAT}"

    # ── Workspaces ──────────────────────────────────────────────────────────
    info "Configuring workspaces..."
    safe_gsettings set org.gnome.mutter dynamic-workspaces true
    safe_gsettings set org.gnome.mutter workspaces-only-on-primary false

    # ── Animations ──────────────────────────────────────────────────────────
    safe_gsettings set org.gnome.desktop.interface enable-animations true

    # ── Touchpad (laptop-friendly defaults) ─────────────────────────────────
    safe_gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
    safe_gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true


    # ── Night Light ─────────────────────────────────────────────────────────
    safe_gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    safe_gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3700

    # ── Extension settings (wrapped in schema checks) ───────────────────────

    # Blur My Shell
    if schema_exists "org.gnome.shell.extensions.blur-my-shell"; then
        info "Configuring Blur My Shell..."
        safe_gsettings set org.gnome.shell.extensions.blur-my-shell.panel blur true
        safe_gsettings set org.gnome.shell.extensions.blur-my-shell.panel sigma 30
        safe_gsettings set org.gnome.shell.extensions.blur-my-shell.overview blur true
        safe_gsettings set org.gnome.shell.extensions.blur-my-shell.overview sigma 30
        safe_gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur true
        safe_gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock sigma 20
    else
        warn "Blur My Shell schema not found — skipping configuration"
    fi

    # Dash to Dock
    if schema_exists "org.gnome.shell.extensions.dash-to-dock"; then
        info "Configuring Dash to Dock..."
        safe_gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
        safe_gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
        safe_gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
        safe_gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
        safe_gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
        safe_gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
        safe_gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.4
        safe_gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DOTS'
        safe_gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
        safe_gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
        safe_gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
        safe_gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
        safe_gsettings set org.gnome.shell.extensions.dash-to-dock apply-custom-theme true
        safe_gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor false
        safe_gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-or-previews'
    else
        warn "Dash to Dock schema not found — skipping configuration"
    fi

    # ArcMenu
    if schema_exists "org.gnome.shell.extensions.arcmenu"; then
        info "Configuring ArcMenu..."
        safe_gsettings set org.gnome.shell.extensions.arcmenu menu-layout 'Eleven'
        safe_gsettings set org.gnome.shell.extensions.arcmenu menu-button-icon 'Distro_Icon'
        safe_gsettings set org.gnome.shell.extensions.arcmenu search-provider-open-windows true
    else
        warn "ArcMenu schema not found — skipping configuration"
    fi

    # Just Perfection
    if schema_exists "org.gnome.shell.extensions.just-perfection"; then
        info "Configuring Just Perfection..."
        safe_gsettings set org.gnome.shell.extensions.just-perfection activities-button false
        safe_gsettings set org.gnome.shell.extensions.just-perfection animation 3
        safe_gsettings set org.gnome.shell.extensions.just-perfection notification-banner-position 2
        safe_gsettings set org.gnome.shell.extensions.just-perfection workspace false
        safe_gsettings set org.gnome.shell.extensions.just-perfection window-demands-attention-focus false
    else
        warn "Just Perfection schema not found — skipping configuration"
    fi

    # Vitals — system monitor in top panel
    if schema_exists "org.gnome.shell.extensions.vitals"; then
        info "Configuring Vitals..."
        safe_gsettings set org.gnome.shell.extensions.vitals position-in-panel 2
        safe_gsettings set org.gnome.shell.extensions.vitals show-storage true
        safe_gsettings set org.gnome.shell.extensions.vitals show-network true
        safe_gsettings set org.gnome.shell.extensions.vitals show-memory true
        safe_gsettings set org.gnome.shell.extensions.vitals show-processor true
        safe_gsettings set org.gnome.shell.extensions.vitals update-time 3
    else
        warn "Vitals schema not found — skipping configuration"
    fi

    # ── Theme Verification ──────────────────────────────────────────────────
    info "Verifying theme application..."
    local applied_theme
    applied_theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'" || true)

    if [[ "$applied_theme" == "${GTK_THEME}" ]]; then
        success "Theme applied successfully: ${GTK_THEME}"
        INSTALL_STATUS[theme_applied]="installed"
    else
        warn "Theme installed but could not be activated automatically"
        warn "Expected: ${GTK_THEME}, Got: ${applied_theme:-unknown}"
        warn "Log out and back in — it will activate on next session"
        INSTALL_STATUS[theme_applied]="failed"
    fi

    success "GNOME configuration applied"
}

reset_gnome_settings() {
    info "Resetting GNOME settings to defaults..."

    # Reset appearance
    safe_gsettings reset org.gnome.desktop.interface color-scheme
    safe_gsettings reset org.gnome.desktop.interface gtk-theme
    safe_gsettings reset org.gnome.desktop.interface icon-theme
    safe_gsettings reset org.gnome.desktop.interface cursor-theme
    safe_gsettings reset org.gnome.desktop.interface cursor-size

    # Reset fonts
    safe_gsettings reset org.gnome.desktop.interface font-name
    safe_gsettings reset org.gnome.desktop.interface document-font-name
    safe_gsettings reset org.gnome.desktop.interface monospace-font-name
    safe_gsettings reset org.gnome.desktop.wm.preferences titlebar-font

    # Reset window management
    safe_gsettings reset org.gnome.desktop.wm.preferences button-layout
    safe_gsettings reset org.gnome.mutter center-new-windows
    safe_gsettings reset org.gnome.desktop.wm.preferences focus-new-windows

    # Reset clock
    safe_gsettings reset org.gnome.desktop.interface clock-show-weekday
    safe_gsettings reset org.gnome.desktop.interface clock-show-date
    safe_gsettings reset org.gnome.desktop.interface clock-format

    # Reset touchpad
    safe_gsettings reset org.gnome.desktop.peripherals.touchpad tap-to-click
    safe_gsettings reset org.gnome.desktop.peripherals.touchpad natural-scroll

    success "GNOME settings reset to defaults"
}
