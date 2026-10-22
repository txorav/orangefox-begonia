#!/system/bin/sh
#
# Hardware & Battery Telemetry
#

batt_pct=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null)
[ -z "$batt_pct" ] && batt_pct="N/A"

batt_volt=$(cat /sys/class/power_supply/battery/voltage_now 2>/dev/null)
if [ -n "$batt_volt" ] && [ "$batt_volt" -gt 1000 ]; then
    batt_volt="$((batt_volt / 1000)) mV"
else
    batt_volt="N/A"
fi

batt_temp=$(cat /sys/class/power_supply/battery/temp 2>/dev/null)
if [ -n "$batt_temp" ]; then
    batt_temp="$((batt_temp / 10))°C"
else
    batt_temp="N/A"
fi

charging_status=$(cat /sys/class/power_supply/battery/status 2>/dev/null)
[ -z "$charging_status" ] && charging_status="Discharging"

cpu_temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
if [ -n "$cpu_temp" ]; then
    cpu_temp="$((cpu_temp / 1000))°C"
else
    cpu_temp="N/A"
fi

cat <<EOF
Battery Level   : $batt_pct% ($charging_status)
Battery Voltage : $batt_volt
Battery Temp    : $batt_temp
CPU Temperature : $cpu_temp
EOF
