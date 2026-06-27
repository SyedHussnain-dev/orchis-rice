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
  ██╔══██╗██╔══██╗██╔════╝██║  ██║██║██╔════╝
  ██████╔╝██████╔╝██║     ███████║██║███████╗
  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚════██║
  ██║     ██║  ██║╚██████╗██║  ██║██║███████║
  ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚══════╝
EOF
    printf "${RESET}\n"
}

# ── Installation Flow ───────────────────────────────────────────────────────
run_installation() {
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
    local end_time
    end_time=$(date +%s)
    local elapsed=$((end_time - START_TIME))

    printf "\n"
    printf "${BOLD}${GREEN}  ========================================${RESET}\n"
    printf "\n"
    printf "${BOLD}${GREEN}  Installation Complete!${RESET}\n"
    printf "\n"
    printf "  ${BOLD}Installed Theme:${RESET}  Orchis Dark\n"
    printf "  ${BOLD}Installed Icons:${RESET}  Tela Circle Dark\n"
    printf "  ${BOLD}Installed Cursor:${RESET} Bibata Modern Ice\n"
    printf "  ${BOLD}GNOME Settings:${RESET}   Applied\n"
    printf "  ${BOLD}Wallpaper:${RESET}        %s\n" "$SELECTED_WALLPAPER"
    printf "  ${BOLD}Time Elapsed:${RESET}     %s\n" "$(format_time "$elapsed")"
    printf "\n"
    printf "  ${BOLD}${YELLOW}Next Steps:${RESET}\n"
    printf "  1. Log out and log back in to ensure all changes take effect.\n"
    printf "  2. Enjoy your beautiful desktop!\n"
    printf "\n"
    printf "${BOLD}${GREEN}  ========================================${RESET}\n"
    printf "\n"
    exit 0
}

# ── Main Menu ───────────────────────────────────────────────────────────────
main() {
    clear || true
    printf "\n"
    printf "${BOLD}${MAGENTA}  ======================================================${RESET}\n"
    print_logo
    printf "${CYAN}             Ubuntu 24.04 Desktop Installer${RESET}\n"
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
