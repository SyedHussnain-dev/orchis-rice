#!/usr/bin/env bash
# install.sh — Main installer for Orchis Rice

set -Eeuo pipefail

# ── Setup ───────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Source scripts
# shellcheck source=scripts/utils.sh
source "${SCRIPT_DIR}/scripts/utils.sh"
# shellcheck source=scripts/dependencies.sh
source "${SCRIPT_DIR}/scripts/dependencies.sh"
# shellcheck source=scripts/themes.sh
source "${SCRIPT_DIR}/scripts/themes.sh"
# shellcheck source=scripts/icons.sh
source "${SCRIPT_DIR}/scripts/icons.sh"
# shellcheck source=scripts/cursor.sh
source "${SCRIPT_DIR}/scripts/cursor.sh"
# shellcheck source=scripts/fonts.sh
source "${SCRIPT_DIR}/scripts/fonts.sh"
# shellcheck source=scripts/extensions.sh
source "${SCRIPT_DIR}/scripts/extensions.sh"
# shellcheck source=scripts/gnome.sh
source "${SCRIPT_DIR}/scripts/gnome.sh"
# shellcheck source=scripts/wallpaper.sh
source "${SCRIPT_DIR}/scripts/wallpaper.sh"
# shellcheck source=scripts/backup.sh
source "${SCRIPT_DIR}/scripts/backup.sh"

# Global variables for summary
START_TIME=$(date +%s)
SELECTED_WALLPAPER="None"

# ── Logo ────────────────────────────────────────────────────────────────────
print_logo() {
    printf "${BOLD}${MAGENTA}"
    cat << "EOF"
   ██████╗ ██████╗  ██████╗██╗  ██╗██╗███████╗
  ██╔═══██╗██╔══██╗██╔════╝██║  ██║██║██╔════╝
  ██║   ██║██████╔╝██║     ███████║██║███████╗
  ██║   ██║██╔══██╗██║     ██╔══██║██║╚════██║
  ╚██████╔╝██║  ██║╚██████╗██║  ██║██║███████║
   ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚══════╝
EOF
    printf "${RESET}\n"
}

# ── Installation Summary ───────────────────────────────────────────────────
print_summary() {
    local end_time
    end_time=$(date +%s)
    local elapsed=$((end_time - START_TIME))

    # Determine status labels
    local theme_status="Installed"
    local icon_status="Installed"
    local cursor_status="Installed"
    local font_status="Installed"

    case "${INSTALL_STATUS[fonts]:-installed}" in
        partial) font_status="Partial (check warnings above)" ;;
        failed)  font_status="Failed" ;;
    esac

    case "${INSTALL_STATUS[theme_applied]:-installed}" in
        failed) theme_status="Installed (activation failed)" ;;
    esac

    printf "\n"
    printf "${BOLD}${GREEN}  ====================================================${RESET}\n"
    printf "\n"
    printf "${BOLD}${GREEN}  🌸 Orchis Rice Installation Complete${RESET}\n"
    printf "\n"
    printf "  ${BOLD}Theme:${RESET}        %s\n" "${GTK_THEME} — ${theme_status}"
    printf "  ${BOLD}Icons:${RESET}        %s\n" "${ICON_THEME} — ${icon_status}"
    printf "  ${BOLD}Cursor:${RESET}       %s\n" "${CURSOR_THEME} — ${cursor_status}"
    printf "  ${BOLD}Fonts:${RESET}        %s\n" "${font_status}"
    printf "  ${BOLD}Wallpaper:${RESET}    %s\n" "$SELECTED_WALLPAPER"
    printf "\n"

    # Extension results
    if [[ ${#EXTENSION_RESULTS[@]} -gt 0 ]]; then
        printf "  ${BOLD}Extensions:${RESET}\n"
        for ext_result in "${EXTENSION_RESULTS[@]}"; do
            if [[ "$ext_result" == ✓* ]]; then
                printf "    ${GREEN}%s${RESET}\n" "$ext_result"
            else
                printf "    ${YELLOW}%s${RESET}\n" "$ext_result"
            fi
        done
        printf "\n"
    fi

    printf "  ${BOLD}Installation Time:${RESET}  %s\n" "$(format_time "$elapsed")"
    printf "  ${BOLD}Log File:${RESET}           %s\n" "${LOG_FILE}"
    printf "\n"
    printf "  ${BOLD}${YELLOW}Next Steps:${RESET}\n"
    printf "  1. Log out and log back in to ensure all changes take effect.\n"
    printf "  2. Enjoy your beautiful desktop!\n"
    printf "\n"
    printf "${BOLD}${GREEN}  ====================================================${RESET}\n"
    printf "\n"
}

# ── Installation Flow ───────────────────────────────────────────────────────
run_installation() {
    # Load configuration
    load_config

    # Set up logging
    setup_logging

    # Pre-flight checks
    info "Checking system requirements..."
    check_os || {
        warn "This script might not work correctly on this OS."
    }
    check_gnome || {
        warn "Some GNOME configuration might fail."
    }

    # Ensure cleanup on exit
    trap cleanup_temp EXIT

    # Clean up any stale temp from a previous failed run
    cleanup_temp

    # Reset step counter
    CURRENT_STEP=0
    TOTAL_STEPS=8

    # Let user configure Orchis theme options before installing
    printf "\n"
    printf "  ${BOLD}${CYAN}Would you like to configure Orchis theme options? [y/N]:${RESET} "
    read -r configure_choice
    if [[ "${configure_choice,,}" == "y" || "${configure_choice,,}" == "yes" ]]; then
        configure_theme false
    else
        info "Using default theme configuration"
    fi

    # Run installation steps
    install_dependencies
    install_theme
    install_icons
    install_cursor
    install_fonts
    install_extensions
    apply_gnome_settings
    select_wallpaper

    # Clean up explicitly
    cleanup_temp
    trap - EXIT

    # Summary
    print_summary
    exit 0
}

# ── Configure Theme ─────────────────────────────────────────────────────────
configure_theme() {
    local from_menu="${1:-true}"

    if [[ "$from_menu" == "true" ]]; then
        clear || true
    fi
    printf "\n"
    printf "${BOLD}${MAGENTA}  ======================================================${RESET}\n"
    printf "${CYAN}             Configure Orchis Theme Options${RESET}\n"
    printf "${BOLD}${MAGENTA}  ======================================================${RESET}\n"
    printf "\n"

    # Ensure config is loaded first to show current defaults
    load_config >/dev/null 2>&1

    # ── Theme Variant ───────────────────────────────────────────────────────
    printf "  ${BOLD}Theme Variant${RESET}\n"
    printf "  ${DIM}Options: default, purple, pink, red, orange, yellow, green, teal, grey, all${RESET}\n"
    printf "  Current [${CYAN}${ORCHIS_THEME_VARIANT:-default}${RESET}]: "
    read -r t_var
    [[ -n "$t_var" ]] && ORCHIS_THEME_VARIANT="$t_var"

    # ── Color Variant ───────────────────────────────────────────────────────
    printf "\n  ${BOLD}Color Variant${RESET}\n"
    printf "  ${DIM}Options: standard, light, dark  (Default: All variants)${RESET}\n"
    printf "  Current [${CYAN}${ORCHIS_COLOR_VARIANT:-dark}${RESET}]: "
    read -r c_var
    [[ -n "$c_var" ]] && ORCHIS_COLOR_VARIANT="$c_var"

    # ── Size Variant ────────────────────────────────────────────────────────
    printf "\n  ${BOLD}Size Variant${RESET}\n"
    printf "  ${DIM}Options: standard, compact  (Default: All variants)${RESET}\n"
    printf "  Current [${CYAN}${ORCHIS_SIZE_VARIANT:-all}${RESET}]: "
    read -r s_var
    [[ -n "$s_var" ]] && ORCHIS_SIZE_VARIANT="$s_var"

    # ── Icon Variant ────────────────────────────────────────────────────────
    printf "\n  ${BOLD}Shell Panel Activities Icon${RESET}\n"
    printf "  ${DIM}Options: default, apple, simple, gnome, ubuntu, arch, manjaro, fedora,${RESET}\n"
    printf "  ${DIM}         debian, void, opensuse, popos, mxlinux, zorin, endeavouros,${RESET}\n"
    printf "  ${DIM}         tux, nixos, gentoo, budgie, solus, kali  (Default: ChromeOS style)${RESET}\n"
    printf "  Current [${CYAN}${ORCHIS_ICON_VARIANT:-chromeos}${RESET}]: "
    read -r i_var
    [[ -n "$i_var" ]] && ORCHIS_ICON_VARIANT="$i_var"

    # ── Tweaks ──────────────────────────────────────────────────────────────
    printf "\n  ${BOLD}Tweaks${RESET} ${DIM}(space-separated, options can mix)${RESET}\n"
    printf "  ${DIM}  solid     — No transparency panel variant${RESET}\n"
    printf "  ${DIM}  compact   — No floating panel variant${RESET}\n"
    printf "  ${DIM}  black     — Full black variant${RESET}\n"
    printf "  ${DIM}  primary   — Radio icon checked color → primary theme color${RESET}\n"
    printf "  ${DIM}  macos     — macOS-style window buttons${RESET}\n"
    printf "  ${DIM}  submenu   — Normal submenus color contrast${RESET}\n"
    printf "  ${DIM}  nord      — Nord colorscheme${RESET}\n"
    printf "  ${DIM}  dracula   — Dracula colorscheme  (nord and dracula cannot mix!)${RESET}\n"
    printf "  ${DIM}  dock      — Fix style for dash-to-dock / ubuntu-dock${RESET}\n"
    printf "  Current [${CYAN}${ORCHIS_TWEAKS:-macos}${RESET}]: "
    read -r tw_var
    [[ -n "$tw_var" ]] && ORCHIS_TWEAKS="$tw_var"

    # ── Round Corners ───────────────────────────────────────────────────────
    printf "\n  ${BOLD}Round Corner Radius${RESET}\n"
    printf "  ${DIM}Enter a px value (suggested: 2px < value < 16px, e.g. 5px, 8px, 12px)${RESET}\n"
    printf "  Current [${CYAN}${ORCHIS_ROUND:-auto}${RESET}]: "
    read -r r_var
    [[ -n "$r_var" ]] && ORCHIS_ROUND="$r_var"

    # ── Libadwaita ──────────────────────────────────────────────────────────
    printf "\n  ${BOLD}Link to libadwaita apps${RESET}\n"
    printf "  ${DIM}Links installed Orchis gtk-4.0 theme to config folder for libadwaita apps${RESET}\n"
    printf "  Current [${CYAN}${ORCHIS_LIBADWAITA:-false}${RESET}]: "
    read -r l_var
    [[ -n "$l_var" ]] && ORCHIS_LIBADWAITA="$l_var"

    # ── Fixed Accent ────────────────────────────────────────────────────────
    printf "\n  ${BOLD}Fixed accent (blue) color for GNOME Shell >= 47${RESET}\n"
    printf "  ${DIM}Options: true, false${RESET}\n"
    printf "  Current [${CYAN}${ORCHIS_FIXED:-false}${RESET}]: "
    read -r f_var
    [[ -n "$f_var" ]] && ORCHIS_FIXED="$f_var"

    # ── Shell Version ───────────────────────────────────────────────────────
    printf "\n  ${BOLD}GNOME Shell Version Override${RESET}\n"
    printf "  ${DIM}Options: 38, 40, 42, 44, 46, 47, 48  (leave empty to auto-detect)${RESET}\n"
    printf "  Current [${CYAN}${ORCHIS_SHELL_VERSION:-auto-detect}${RESET}]: "
    read -r sh_var
    [[ -n "$sh_var" ]] && ORCHIS_SHELL_VERSION="$sh_var"

    # ── Save to config ──────────────────────────────────────────────────────
    if [[ -f "$CONFIG_FILE" ]]; then
        sed -i "s/^ORCHIS_THEME_VARIANT=.*/ORCHIS_THEME_VARIANT=\"$ORCHIS_THEME_VARIANT\"/" "$CONFIG_FILE"
        sed -i "s/^ORCHIS_COLOR_VARIANT=.*/ORCHIS_COLOR_VARIANT=\"$ORCHIS_COLOR_VARIANT\"/" "$CONFIG_FILE"
        sed -i "s/^ORCHIS_SIZE_VARIANT=.*/ORCHIS_SIZE_VARIANT=\"$ORCHIS_SIZE_VARIANT\"/" "$CONFIG_FILE"
        sed -i "s/^ORCHIS_ICON_VARIANT=.*/ORCHIS_ICON_VARIANT=\"$ORCHIS_ICON_VARIANT\"/" "$CONFIG_FILE"
        sed -i "s/^ORCHIS_TWEAKS=.*/ORCHIS_TWEAKS=\"$ORCHIS_TWEAKS\"/" "$CONFIG_FILE"
        sed -i "s/^ORCHIS_ROUND=.*/ORCHIS_ROUND=\"$ORCHIS_ROUND\"/" "$CONFIG_FILE"
        sed -i "s/^ORCHIS_LIBADWAITA=.*/ORCHIS_LIBADWAITA=\"$ORCHIS_LIBADWAITA\"/" "$CONFIG_FILE"
        sed -i "s/^ORCHIS_FIXED=.*/ORCHIS_FIXED=\"$ORCHIS_FIXED\"/" "$CONFIG_FILE"
        sed -i "s/^ORCHIS_SHELL_VERSION=.*/ORCHIS_SHELL_VERSION=\"$ORCHIS_SHELL_VERSION\"/" "$CONFIG_FILE"

        printf "\n  ${GREEN}✓ Configuration saved to ${CONFIG_FILE}${RESET}\n"
    else
        printf "\n  ${RED}✗ Config file not found at ${CONFIG_FILE}${RESET}\n"
    fi

    if [[ "$from_menu" == "true" ]]; then
        printf "\n  Press Enter to return to main menu..."
        read -r
    fi
}


# ── Main Menu ───────────────────────────────────────────────────────────────
show_menu() {
    clear || true
    printf "\n"
    printf "${BOLD}${MAGENTA}  ======================================================${RESET}\n"
    print_logo
    printf "${CYAN}               Linux Desktop Installer${RESET}\n"
    printf "${BOLD}${MAGENTA}  ======================================================${RESET}\n"
    printf "\n"
    printf "  ${BOLD}1.${RESET} Install\n"
    printf "  ${BOLD}2.${RESET} Update (Fetch latest updates and reinstall)\n"
    printf "  ${BOLD}3.${RESET} Uninstall\n"
    printf "  ${BOLD}4.${RESET} Backup Settings\n"
    printf "  ${BOLD}5.${RESET} Configure Orchis Theme\n"
    printf "  ${BOLD}6.${RESET} Exit\n"
    printf "\n"
    printf "${BOLD}${MAGENTA}  ======================================================${RESET}\n"
    printf "\n"
}

main() {
    show_menu

    while true; do
        printf "  ${BOLD}Select an option [1-6]:${RESET} "
        read -r choice

        case "$choice" in
            1|2)
                if [[ "$choice" == "2" ]]; then
                    info "Pulling latest updates..."
                    git pull || warn "Could not pull latest updates (maybe not a git repository)"
                fi
                run_installation
                break
                ;;
            3)
                if [[ -x "${ORCHIS_RICE_DIR}/uninstall.sh" ]]; then
                    "${ORCHIS_RICE_DIR}/uninstall.sh"
                else
                    bash "${ORCHIS_RICE_DIR}/uninstall.sh"
                fi
                break
                ;;
            4)
                backup_settings
                show_menu
                ;;
            5)
                configure_theme
                show_menu
                ;;
            6)
                info "Exiting."
                exit 0
                ;;
            *)
                warn "Invalid selection."
                ;;
        esac
    done
}

# Execute main menu if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
