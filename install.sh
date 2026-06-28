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
    check_ubuntu || {
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

# ── Main Menu ───────────────────────────────────────────────────────────────
main() {
    clear || true
    printf "\n"
    printf "${BOLD}${MAGENTA}  ======================================================${RESET}\n"
    print_logo
    printf "${CYAN}               Ubuntu Desktop Installer${RESET}\n"
    printf "${BOLD}${MAGENTA}  ======================================================${RESET}\n"
    printf "\n"
    printf "  ${BOLD}1.${RESET} Install\n"
    printf "  ${BOLD}2.${RESET} Update (Fetch latest updates and reinstall)\n"
    printf "  ${BOLD}3.${RESET} Uninstall\n"
    printf "  ${BOLD}4.${RESET} Backup Settings\n"
    printf "  ${BOLD}5.${RESET} Exit\n"
    printf "\n"
    printf "${BOLD}${MAGENTA}  ======================================================${RESET}\n"
    printf "\n"

    while true; do
        printf "  ${BOLD}Select an option [1-5]:${RESET} "
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
