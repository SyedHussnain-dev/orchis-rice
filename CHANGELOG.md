# Changelog

All notable changes to Orchis Rice are documented here.

---

## [Unreleased]

### Fixed
- **Blur My Shell UUID**: corrected from `blur-my-shell@auber` to `blur-my-shell@auber.me` — the wrong UUID caused automatic install to silently fail

### Added
- **Vitals extension** (`Vitals@CoreCoding.com`): adds CPU, RAM, disk, and network stats to the top panel
- **Vitals gsettings configuration** in gnome.sh — positioned right side, shows processor, memory, storage, and network by default
- **Dash to Dock**: added `click-action focus-or-previews` and `multi-monitor false`
- **Blur My Shell**: added dash-to-dock blur configuration
- **Just Perfection**: added `workspace false` and `window-demands-attention-focus false`
- **Touchpad defaults**: tap-to-click and natural scroll enabled by default
- `dconf-cli` added to dependencies for reliable dconf backup support
- Theme install now checks both `~/.themes` and `~/.local/share/themes`
- Font install now skips web/variable font variants (faster, smaller)

### Removed
- **Tiling Assistant** extension: removed from auto-install list (not part of the core look, UUID was outdated, caused conflicts on some setups)

### Improved
- Extension fallback guide now mentions the log-out requirement and schema ordering note
- `dependencies.sh`: fixed empty array edge case in `get_missing_packages`
- `fonts.sh`: cleaner download error handling, better fc-list verification messaging
- `icons.sh`: post-install directory verification with warning (non-fatal)
- `wallpaper.sh`: extracted `apply_wallpaper()` as a separate function for reuse
- `wallpapers/README.md`: added curated list of free dark wallpaper sources

---

## [0.1.0] — Initial Release

- Orchis Dark GTK theme
- Tela Circle Dark icons
- Bibata Modern Ice cursor
- Inter + JetBrains Mono Nerd Font
- GNOME extensions: Blur My Shell, Dash to Dock, ArcMenu, Just Perfection, Clipboard Indicator, Caffeine
- AppIndicator via apt
- Wallpaper selection with bundled images
- dconf backup before installation
- config/default.conf for user customisation
- Uninstaller with confirmation prompt
- Installation summary with timing
