# Boot Splash Screen

Place your custom splash screen image here as `splash.png`.

## Requirements

- Format: PNG
- Recommended resolution: 1920x1080 for Full HD displays
- For portrait mode: 1080x1920

## How it works

The splash screen is displayed during boot using the `fbi` (framebuffer imageviewer) tool. It will hide the console output during boot until MagicMirror starts.

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
