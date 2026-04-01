# Crunch

A macOS menu bar app that converts images to WebP, JPEG, PNG, or HEIC with drag & drop.

Drop files, paste from clipboard, or click to select — pick your format and quality, then crunch.

## Features

- **Drag & drop** — drop images directly onto the floating panel
- **Click to select** — open a file picker from the drop zone
- **Clipboard paste** — ⌘V to paste images
- **Format picker** — WebP, JPEG, PNG, HEIC
- **Quality slider** — control compression (10–100%)
- **Batch conversion** — convert multiple images at once
- **Before/after stats** — see original vs. compressed size with savings %
- **Show in Finder** — reveal converted files instantly
- **Stays open** — panel doesn't close when switching apps (custom NSPanel)

## Build & Run

Requires `cwebp` for WebP encoding:

```bash
brew install webp
```

Then:

```bash
swift build
.build/debug/Crunch
```

## License

MIT
