# Approved Android launcher icon — 2026-10-27

Owner-approved source: `assets/branding/centerly-launcher-v2-approved.png`.
Generated with the built-in image generation tool; references were the C icon concept and the existing Centerly graduation-cap/books/green-check logo. Prompt direction: preserve the recognizable cap, upright pages and green ascending check, combine with the polished concept, full-bleed app-blue background (#246EFA / #1558D6), pale-blue mark, restrained satin depth, no text, border or white backing plate. This is the exact generated artwork approved by the owner, copied without creative changes.

Regenerate Android density PNGs using `powershell -NoProfile -File tools/generate_android_launcher.ps1` from the repository. The script only resamples artwork to 48/72/96/144/192 pixels. The existing AndroidManifest references @mipmap/ic_launcher. Source remains outside Flutter runtime asset bundles.

Reviewed the generated 192px icon visually and verified all five output dimensions. No native installation, device launcher acceptance, release build, distribution or website changes performed. Hot Reload cannot replace the OS launcher icon: the next normal Android build/install picks up these resources; some launchers may cache the old icon.
