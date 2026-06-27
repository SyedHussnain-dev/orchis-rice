#!/usr/bin/env bash
# uninstall.sh — Clean uninstaller for Orchis Rice

set -Eeuo pipefail

# ── Setup ───────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Source scripts
# shellcheck source=scripts/utils.sh
source "${SCRIPT_DIR}/scripts/utils.sh"
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

# ── Main ────────────────────────────────────────────────────────────────────
main() {
    clear
    printf "\n"
    printf "${BOLD}${RED}  ========================================${RESET}\n"
    printf "\n"
    printf "${BOLD}${RED}  🌸 ORCHIS RICE UNINSTALLER${RESET}\n"
    printf "\n"
    printf "${CYAN}  Removing customizations and reverting settings...${RESET}\n"
    printf "\n"
    printf "${BOLD}${RED}  ========================================${RESET}\n"
    printf "\n"

    printf "  ${BOLD}This will remove:${RESET}\n"
    printf "  - Orchis themes\n"
    printf "  - Tela Circle icons\n"
    printf "  - Bibata cursors\n"
    printf "  - Inter and JetBrains Mono fonts\n"
    printf "  - Disable installed GNOME extensions\n"
    printf "  - Reset GNOME settings to defaults\n"
    printf "\n"
    
    local confirm
    printf "  ${BOLD}Are you sure you want to proceed? [y/N]:${RESET} "
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        info "Uninstallation cancelled."
        exit 0
    fi

    # Run uninstallation steps
    remove_theme
    remove_icons
    remove_cursor
    remove_fonts
    remove_extensions
    reset_gnome_settings

    printf "\n"
    printf "${BOLD}${GREEN}  ========================================${RESET}\n"
    printf "\n"
    printf "${BOLD}${GREEN}  Uninstallation Complete!${RESET}\n"
    printf "\n"
    printf "  ${BOLD}${YELLOW}Note:${RESET}\n"
    printf "  1. System packages (gnome-tweaks, pipx, etc.) were NOT removed.\n"
    printf "  2. Log out and log back in to ensure all changes take effect.\n"
    printf "\n"
    printf "${BOLD}${GREEN}  ========================================${RESET}\n"
    printf "\n"
}

main "$@"
