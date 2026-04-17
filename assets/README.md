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

**Note:** The splash will be visible for ~30-60 seconds during boot.

## Suppressing console output

To hide boot messages and only show the splash screen, edit the kernel command line:

```bash
sudo nano /boot/firmware/cmdline.txt
```

Add these parameters to the end of the line:
```
quiet splash loglevel=3 vt.global_cursor_default=0
```

**Before:**
```
console=serial0,115200 console=tty1 root=PARTUUID=... rootfstype=ext4 ...
```

**After:**
```
console=serial0,115200 console=tty1 root=PARTUUID=... rootfstype=ext4 ... quiet splash loglevel=3 vt.global_cursor_default=0
```

**Important:** 
- On modern Raspberry Pi OS, use `/boot/firmware/cmdline.txt` (not `/boot/cmdline.txt`)
- Keep everything on ONE line
- Reboot to apply: `sudo reboot`

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
