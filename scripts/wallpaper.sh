#!/usr/bin/env bash
# wallpaper.sh — Wallpaper selection and application

set -Eeuo pipefail

# shellcheck source=utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

WALLPAPER_DIR="${ORCHIS_RICE_DIR}/assets/wallpapers"

select_wallpaper() {
    header "Wallpaper Selection"

    # Find image files in wallpaper directory
    local wallpapers=()
    if [[ -d "$WALLPAPER_DIR" ]]; then
        while IFS= read -r -d '' file; do
            wallpapers+=("$file")
        done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) -print0 | sort -z)
    fi

    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        info "No wallpapers found in assets/wallpapers/"
        info ""
        info "To add wallpapers:"
        info "  1. Place image files (.jpg, .png, .webp) in:"
        info "     ${WALLPAPER_DIR}/"
        info "  2. Run this installer again"
        info ""
        info "Skipping wallpaper selection"
        return 0
    fi

    # Display wallpaper selection menu
    printf "\n"
    printf "${BOLD}  Available wallpapers:${RESET}\n"
    printf "\n"

    for i in "${!wallpapers[@]}"; do
        local name
        name=$(basename "${wallpapers[$i]}")
        printf "    ${CYAN}%d${RESET}) %s\n" $((i + 1)) "$name"
    done

    printf "    ${DIM}%d) Skip wallpaper${RESET}\n" $((${#wallpapers[@]} + 1))
    printf "\n"

    # Read user selection
    local choice
    while true; do
        printf "  ${BOLD}Select wallpaper [1-%d]:${RESET} " $((${#wallpapers[@]} + 1))
        read -r choice

        # Default to first wallpaper if empty
        if [[ -z "$choice" ]]; then
            choice=1
        fi

        # Validate input
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le $((${#wallpapers[@]} + 1)) ]]; then
            break
        fi

        warn "Invalid selection — try again"
    done

    # Skip if user chose the skip option
    if [[ "$choice" -eq $((${#wallpapers[@]} + 1)) ]]; then
        info "Skipping wallpaper"
        return 0
    fi

    # Apply selected wallpaper
    local selected="${wallpapers[$((choice - 1))]}"
    local selected_name
    selected_name=$(basename "$selected")
    local wallpaper_uri="file://${selected}"

    info "Setting wallpaper: ${selected_name}"

    # Set for both light and dark mode
    safe_gsettings set org.gnome.desktop.background picture-uri "$wallpaper_uri"
    safe_gsettings set org.gnome.desktop.background picture-uri-dark "$wallpaper_uri"
    safe_gsettings set org.gnome.desktop.background picture-options 'zoom'

    # Set lock screen wallpaper too
    safe_gsettings set org.gnome.desktop.screensaver picture-uri "$wallpaper_uri"
    safe_gsettings set org.gnome.desktop.screensaver picture-options 'zoom'

    SELECTED_WALLPAPER="$selected_name"
    success "Wallpaper set: ${selected_name}"
}
