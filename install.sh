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
    clear || true
    printf "\n"
    printf "${BOLD}${MAGENTA}  ======================================================${RESET}\n"
    printf "${CYAN}             Configure Orchis Theme Options${RESET}\n"
    printf "${BOLD}${MAGENTA}  ======================================================${RESET}\n"
    printf "\n"
    
    # Ensure config is loaded first to show current defaults
    load_config >/dev/null 2>&1

    printf "  ${BOLD}Theme Variant (default, purple, pink, red, orange, yellow, green, teal, grey, all)${RESET}\n"
    printf "  Current [${ORCHIS_THEME_VARIANT:-default}]: "
    read -r t_var
    [[ -n "$t_var" ]] && ORCHIS_THEME_VARIANT="$t_var"
    
    printf "\n  ${BOLD}Color Variant (standard, light, dark)${RESET}\n"
    printf "  Current [${ORCHIS_COLOR_VARIANT:-dark}]: "
    read -r c_var
    [[ -n "$c_var" ]] && ORCHIS_COLOR_VARIANT="$c_var"

    printf "\n  ${BOLD}Size Variant (standard, compact)${RESET}\n"
    printf "  Current [${ORCHIS_SIZE_VARIANT:-}]: "
    read -r s_var
    [[ -n "$s_var" ]] && ORCHIS_SIZE_VARIANT="$s_var"

    printf "\n  ${BOLD}Tweaks (macos, solid, compact, black, primary, submenu, dock)${RESET}\n"
    printf "  Current [${ORCHIS_TWEAKS:-macos}]: "
    read -r tw_var
    [[ -n "$tw_var" ]] && ORCHIS_TWEAKS="$tw_var"

    printf "\n  ${BOLD}Round Corners (e.g. 5px, 8px, 12px)${RESET}\n"
    printf "  Current [${ORCHIS_ROUND:-}]: "
    read -r r_var
    [[ -n "$r_var" ]] && ORCHIS_ROUND="$r_var"

    printf "\n  ${BOLD}Link to libadwaita apps (true/false)${RESET}\n"
    printf "  Current [${ORCHIS_LIBADWAITA:-false}]: "
    read -r l_var
    [[ -n "$l_var" ]] && ORCHIS_LIBADWAITA="$l_var"
    
    # Save back to config/default.conf using sed
    if [[ -f "$CONFIG_FILE" ]]; then
        sed -i "s/^ORCHIS_THEME_VARIANT=.*/ORCHIS_THEME_VARIANT=\"$ORCHIS_THEME_VARIANT\"/" "$CONFIG_FILE"
        sed -i "s/^ORCHIS_COLOR_VARIANT=.*/ORCHIS_COLOR_VARIANT=\"$ORCHIS_COLOR_VARIANT\"/" "$CONFIG_FILE"
        sed -i "s/^ORCHIS_SIZE_VARIANT=.*/ORCHIS_SIZE_VARIANT=\"$ORCHIS_SIZE_VARIANT\"/" "$CONFIG_FILE"
        sed -i "s/^ORCHIS_TWEAKS=.*/ORCHIS_TWEAKS=\"$ORCHIS_TWEAKS\"/" "$CONFIG_FILE"
        sed -i "s/^ORCHIS_ROUND=.*/ORCHIS_ROUND=\"$ORCHIS_ROUND\"/" "$CONFIG_FILE"
        sed -i "s/^ORCHIS_LIBADWAITA=.*/ORCHIS_LIBADWAITA=\"$ORCHIS_LIBADWAITA\"/" "$CONFIG_FILE"
        
        printf "\n  ${GREEN}✓ Configuration saved to ${CONFIG_FILE}${RESET}\n"
    else
        printf "\n  ${RED}✗ Config file not found at ${CONFIG_FILE}${RESET}\n"
    fi

    printf "\n  Press Enter to return to main menu..."
    read -r
}


# ── Main Menu ───────────────────────────────────────────────────────────────
main() {
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
                ;;
            5)
                configure_theme
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
