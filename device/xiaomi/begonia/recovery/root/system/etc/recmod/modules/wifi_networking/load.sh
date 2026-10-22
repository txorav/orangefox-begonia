#!/system/bin/sh
#
# MediaTek Wi-Fi & WMT Stack Loader
#

echo "-> Starting MediaTek WMT loader and launcher..."
if command -v foxwifi >/dev/null 2>&1; then
    foxwifi start
else
    /system/bin/wmt_loader 2>/dev/null || true
    sleep 1
    /system/bin/wmt_launcher -p /vendor/firmware 2>/dev/null &
    sleep 1
    ip link set dev wlan0 up 2>/dev/null || ifconfig wlan0 up 2>/dev/null || true
fi

echo "-> Wi-Fi networking stack is active in RAM."
exit 0
