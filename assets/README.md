# Boot Splash Screen

Place your custom splash screen image here as `splash.png`.

## Requirements

- Format: PNG
- Recommended resolution: 1920x1080 for Full HD displays
- For portrait mode: 1080x1920

## How it works

The splash screen is displayed during boot using:
1. **mm-splash.service** - Shows splash.png at boot start
2. **mm-splash-stop.service** - Removes splash when Docker starts
3. Uses `fbi` (framebuffer imageviewer) to display the image
4. **Automatic silent boot configuration** - install.sh automatically configures boot parameters

**Note:** The splash will be visible for ~30-60 seconds during boot.

## Silent Boot (Automatic)

The `install.sh` script **automatically** configures silent boot when setting up the splash screen:

✅ **What's configured automatically:**
- Suppresses console messages (`quiet splash loglevel=0`)
- Hides boot logos (`logo.nologo`)
- Disables cursor blinking (`vt.global_cursor_default=0`)
- Redirects console to invisible tty (`console=tty3`)
- Disables login prompt on tty1 (getty)
- Hides framebuffer cursor

**Result:** Clean boot experience showing only the splash screen until MagicMirror appears.

### Manual verification

If you want to check the configuration:

```bash
cat /boot/firmware/cmdline.txt
```

You should see these parameters:
```
quiet splash loglevel=0 logo.nologo vt.global_cursor_default=0 console=tty3
```

**Backup:** The original cmdline.txt is saved as `/boot/firmware/cmdline.txt.backup`

### Reverting to console boot

To show console messages again:

```bash
sudo cp /boot/firmware/cmdline.txt.backup /boot/firmware/cmdline.txt
sudo systemctl enable getty@tty1.service
sudo reboot
```

## Creating a custom splash screen

You can create a custom splash screen with:
- Your logo
- Loading animation
- Custom text

Example tools:
- GIMP (free)
- Photoshop
- Canva

## Default behavior

If no splash.png is found, the system will skip the splash screen setup and show normal console output during boot.
