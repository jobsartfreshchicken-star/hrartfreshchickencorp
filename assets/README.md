# Brand assets

Generated from the master logo (`AFCC Logo Upscaled.png`), trimmed to its
content bounding box (portrait, ~7:10 ratio) with transparent background.

| File | Size | Used for |
|---|---|---|
| `logo.png` | 136x192 | Login screen logo, displayed at 96px tall (1x) |
| `logo@2x.png` | 272x384 | Login screen logo, retina (2x) via `srcset` |
| `logo-small.png` | 113x160 | Spare small logo, not currently wired into any page |
| `logo-nav.png` | 57x80 | Sidebar header logo, displayed at 40px tall (2x source for retina) |
| `favicon-16x16.png` | 16x16 | Favicon |
| `favicon-32x32.png` | 32x32 | Favicon |
| `favicon-48x48.png` | 48x48 | Favicon |
| `apple-touch-icon.png` | 180x180 | iOS home screen icon (white background) |
| `../favicon.ico` | 16/32/48 multi-size | Favicon (legacy browsers) |

All files sized by height with `width: auto` to preserve the portrait aspect
ratio — never stretch or squash the logo.
