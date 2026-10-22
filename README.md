# OrangeFox Recovery for Redmi Note 8 Pro (`begonia`)

Automated **GitHub Actions** CI builder and complete device tree for **OrangeFox Recovery R12.1** on **Xiaomi Redmi Note 8 Pro** (`begonia` / `begoniain`).

## Features
- **OrangeFox R12.1** official sync base.
- **FoxWeb & Wi-Fi Stack**: Built-in HTTP server (`foxweb`) and MediaTek WLAN driver (`foxwifi`) allowing browser control, wireless ADB, and zip flashing over LAN.
- **Unified Partition Support**: Mounts both legacy physical partitions and retrofitted dynamic partitions (`super`) with EROFS and EXT4.
- **MIUI/HyperOS Survival**: Automatic OTA survivability.

## Build via GitHub Actions
```bash
gh workflow run "OrangeFox Recovery Build (begonia)"
```
Or trigger manually from the **Actions** tab on GitHub.
