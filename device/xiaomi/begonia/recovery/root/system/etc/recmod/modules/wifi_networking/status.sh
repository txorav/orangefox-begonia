#!/system/bin/sh
#
# Wi-Fi Telemetry Reader
#

ip_addr=$(ip -o -4 addr show wlan0 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n 1)
[ -z "$ip_addr" ] && ip_addr="Not Assigned"

mac_addr=$(cat /sys/class/net/wlan0/address 2>/dev/null)
[ -z "$mac_addr" ] && mac_addr="Unavailable"

link_state="DOWN"
if [ -f /sys/class/net/wlan0/operstate ]; then
    link_state=$(cat /sys/class/net/wlan0/operstate)
fi

cat <<EOF
Interface   : wlan0 ($link_state)
IP Address  : $ip_addr
MAC Address : $mac_addr
Driver      : MT6631/MT7668 Combo
EOF
