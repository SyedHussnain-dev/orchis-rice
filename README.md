```text
██████╗ ██████╗  ██████╗██╗  ██╗██╗███████╗
██╔══██╗██╔══██╗██╔════╝██║  ██║██║██╔════╝
██████╔╝██████╔╝██║     ███████║██║███████╗
██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚════██║
██║     ██║  ██║╚██████╗██║  ██║██║███████║
╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚══════╝
```

> 🌸 A beautiful, automated Ubuntu GNOME customization toolkit.
> Supports Ubuntu 24.04, 24.10, and newer releases.

![Desktop Preview](assets/screenshots/desktop-preview.png)

Transform your standard Ubuntu installation into a polished, modern, and beautiful desktop environment with a single command. Orchis Rice automates the installation and configuration of themes, icons, cursors, fonts, and GNOME extensions.

## Features

- **Automated Installation**: One command handles everything
- **Graceful Error Handling**: Explains issues without silently failing
- **Modular Architecture**: Clean, readable, and maintainable bash scripts
- **Configurable**: Edit `config/default.conf` to customize themes, fonts, and dock favorites
- **Smart Detection**: Automatically finds your browser, editor, and installed fonts
- **Customizable**: Easy to tweak or add your own wallpapers

## What's Included

| Component | Choice |
|-----------|---------|
| **GTK Theme** | [Orchis Dark](https://github.com/vinceliuice/Orchis-theme) |
| **Icon Theme** | [Tela Circle Dark](https://github.com/vinceliuice/Tela-circle-icon-theme) |
| **Cursor** | [Bibata Modern Ice](https://github.com/ful1e5/Bibata_Cursor) |
| **Fonts** | [Inter](https://rsms.me/inter/) & [JetBrains Mono Nerd Font](https://www.nerdfonts.com/) |
| **Extensions** | Blur My Shell, Dash to Dock, ArcMenu, Just Perfection, and more! |

## Installation

```bash
# 1. Clone the repository
git clone https://github.com/SyedHussnain-dev/orchis-rice.git

# 2. Enter the directory
cd orchis-rice

# 3. Make scripts executable
chmod +x install.sh uninstall.sh scripts/*.sh

# 4. Run the installer
./install.sh
```

## Preview

![Installer Preview](assets/screenshots/installer-preview.png)
![Before & After](assets/screenshots/before-after.png)

*(Note: Add screenshot files to `assets/screenshots/`)*

## Configuration

Customize your installation by editing `config/default.conf`. All settings have sensible defaults, so this step is entirely optional.

```bash
# Theme
GTK_THEME="Orchis-Dark"
ICON_THEME="Tela-circle-dark"
CURSOR_THEME="Bibata-Modern-Ice"

# Fonts
FONT_NAME="Inter"
MONOSPACE_FONT="JetBrainsMono Nerd Font"

# Dock favorites (detected automatically — only existing apps are added)
FAVORITES="brave,firefox,code,terminal,files,settings"
```

The installer automatically detects your browser (Brave → Firefox → Chrome → Chromium), code editor (VS Code / Code OSS), and monospace font family. If `config/default.conf` is missing, built-in defaults are used.

## Wallpapers

You can easily add your own wallpapers to the installation process. Simply place your `.jpg`, `.png`, or `.webp` files in the `assets/wallpapers/` directory before running the installer. You will be prompted to select your preferred wallpaper during installation.

## FAQ & Troubleshooting

**Q: The installer failed to configure GNOME extensions.**
A: Automating GNOME extension installation can sometimes be brittle due to updates on extensions.gnome.org. If this happens, the installer will display a detailed recovery guide listing the extensions that need manual installation. The easiest way is to open **Extension Manager** (installed automatically as a dependency) and search for the listed extensions. Alternatively, visit [extensions.gnome.org](https://extensions.gnome.org).

**Q: My terminal looks weird after installing the fonts.**
A: Ensure your terminal emulator is configured to use the newly installed `JetBrainsMono Nerd Font`.

**Q: How do I undo the changes?**
A: Run `./uninstall.sh`. This will remove the themes, icons, cursors, and fonts installed by Orchis Rice, and reset your GNOME settings to defaults.

## Roadmap
- [ ] Add light theme variants
- [ ] Support custom wallpaper downloading via URL
- [ ] Support Arch Linux / Fedora

## Contributing
Contributions are welcome! Please ensure any new bash scripts pass ShellCheck and `bash -n`. Keep functions small and maintain the simple, modular architecture.

## Credits
This project brings together amazing open-source work from:
- [@vinceliuice](https://github.com/vinceliuice) (Orchis Theme & Tela Circle Icons)
- [@ful1e5](https://github.com/ful1e5) (Bibata Cursor)
- [@rsms](https://github.com/rsms) (Inter Font)
- [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)

## License
[MIT License](LICENSE)
