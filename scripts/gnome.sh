#!/usr/bin/env bash
# gnome.sh — Apply GNOME desktop configuration via gsettings

set -Eeuo pipefail

# shellcheck source=utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

apply_gnome_settings() {
    header "Applying GNOME Configuration"

    # ── Appearance ──────────────────────────────────────────────────────────
    info "Setting dark mode..."
    safe_gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    safe_gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Dark'
    safe_gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-dark'
    safe_gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
    safe_gsettings set org.gnome.desktop.interface cursor-size 24

    # ── Fonts ───────────────────────────────────────────────────────────────
    info "Setting fonts..."
    safe_gsettings set org.gnome.desktop.interface font-name 'Inter Regular 11'
    safe_gsettings set org.gnome.desktop.interface document-font-name 'Inter Regular 11'
    safe_gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 13'
    safe_gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Inter Bold 11'

    # ── Font rendering ──────────────────────────────────────────────────────
    safe_gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
    safe_gsettings set org.gnome.desktop.interface font-hinting 'slight'

    # ── Window management ───────────────────────────────────────────────────
    info "Configuring window behavior..."
    safe_gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
    safe_gsettings set org.gnome.mutter center-new-windows true
    safe_gsettings set org.gnome.mutter edge-tiling true

    # ── Clock ───────────────────────────────────────────────────────────────
    info "Configuring clock..."
    safe_gsettings set org.gnome.desktop.interface clock-show-weekday true
    safe_gsettings set org.gnome.desktop.interface clock-show-date true
    safe_gsettings set org.gnome.desktop.interface clock-show-seconds false
    safe_gsettings set org.gnome.desktop.interface clock-format '24h'

    # ── Workspaces ──────────────────────────────────────────────────────────
    info "Configuring workspaces..."
    safe_gsettings set org.gnome.mutter dynamic-workspaces true
    safe_gsettings set org.gnome.mutter workspaces-only-on-primary false

    # ── Animations ──────────────────────────────────────────────────────────
    safe_gsettings set org.gnome.desktop.interface enable-animations true

    # ── Favorite apps in dock ───────────────────────────────────────────────
    info "Setting favorite apps..."
    safe_gsettings set org.gnome.shell favorite-apps \
        "['org.gnome.Nautilus.desktop', 'firefox_firefox.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Settings.desktop', 'org.gnome.TextEditor.desktop']"

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
    else
        warn "Dash to Dock schema not found — skipping configuration"
    fi

    # ArcMenu
    if schema_exists "org.gnome.shell.extensions.arcmenu"; then
        info "Configuring ArcMenu..."
        safe_gsettings set org.gnome.shell.extensions.arcmenu menu-layout 'Eleven'
        safe_gsettings set org.gnome.shell.extensions.arcmenu menu-button-icon 'Distro_Icon'
    else
        warn "ArcMenu schema not found — skipping configuration"
    fi

    # Just Perfection
    if schema_exists "org.gnome.shell.extensions.just-perfection"; then
        info "Configuring Just Perfection..."
        safe_gsettings set org.gnome.shell.extensions.just-perfection activities-button false
        safe_gsettings set org.gnome.shell.extensions.just-perfection animation 3
        safe_gsettings set org.gnome.shell.extensions.just-perfection notification-banner-position 2
    else
        warn "Just Perfection schema not found — skipping configuration"
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

    # Reset favorites
    safe_gsettings reset org.gnome.shell favorite-apps

    # Reset clock
    safe_gsettings reset org.gnome.desktop.interface clock-show-weekday
    safe_gsettings reset org.gnome.desktop.interface clock-show-date
    safe_gsettings reset org.gnome.desktop.interface clock-format

    success "GNOME settings reset to defaults"
}
