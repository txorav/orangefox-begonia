#!/system/bin/sh
#
# MediaTek Wi-Fi & WMT Stack Unloader
#

echo "-> Stopping Wi-Fi stack and bringing wlan0 down..."
if command -v foxwifi >/dev/null 2>&1; then
    foxwifi stop
else
    ip link set dev wlan0 down 2>/dev/null || ifconfig wlan0 down 2>/dev/null || true
    killall wpa_supplicant 2>/dev/null || true
    killall wmt_launcher 2>/dev/null || true
fi

echo "-> Wi-Fi stack unloaded from RAM."
exit 0
