#!/usr/bin/env bash
# backup.sh — Backup GNOME settings before customizing

set -Eeuo pipefail

# shellcheck source=utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

BACKUP_FILE="${HOME}/.orchis-rice-backup.ini"

backup_settings() {
    header "Backing up GNOME settings"

    info "Dumping current dconf settings..."
    
    if command -v dconf &>/dev/null; then
        dconf dump / > "$BACKUP_FILE" || {
            warn "Failed to create dconf backup"
            return 1
        }
        success "Settings backed up to: ${BACKUP_FILE}"
        info "To restore, run: dconf load / < ${BACKUP_FILE}"
    else
        warn "dconf command not found, cannot backup settings"
        return 1
    fi
}
