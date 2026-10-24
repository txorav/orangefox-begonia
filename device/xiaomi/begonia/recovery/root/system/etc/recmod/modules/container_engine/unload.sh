#!/system/bin/sh
for c in /tmp/containers/*; do
    [ -d "$c" ] && /system/bin/foxcontainer stop "$(basename "$c")" 2>/dev/null || true
done
