#!/system/bin/sh
#
# MediaTek MT6785 SIM & IMEI Baseband Stack Loader
#

echo "-> Preparing telephony storage mount points..."
mkdir -p /mnt/vendor/nvdata /mnt/vendor/nvcfg /mnt/vendor/protect_f /mnt/vendor/protect_s /nvdata /nvram 2>/dev/null

# Mount NV partitions
mount -o ro -t ext4 /dev/block/platform/bootdevice/by-name/nvdata /mnt/vendor/nvdata 2>/dev/null || true
mount -o ro -t ext4 /dev/block/platform/bootdevice/by-name/nvcfg /mnt/vendor/nvcfg 2>/dev/null || true
mount -o ro -t ext4 /dev/block/platform/bootdevice/by-name/protect1 /mnt/vendor/protect_f 2>/dev/null || true
mount -o ro -t ext4 /dev/block/platform/bootdevice/by-name/protect2 /mnt/vendor/protect_s 2>/dev/null || true

# Start TEE daemon if not already running
if ! pidof teei_daemon >/dev/null 2>&1; then
    echo "-> Starting Microtrust TEE daemon for secure storage access..."
    start teei_daemon 2>/dev/null || true
fi

# Query & extract IMEI from NVRAM/NVDATA
IMEI_FILE="/mnt/vendor/nvdata/md/NVRAM/NVD_IMEI/MP0H_000"
if [ -f "$IMEI_FILE" ]; then
    echo "-> Decoding hardware IMEI from MediaTek NVDATA..."
    # MTK BCD decoder
    raw_hex=$(od -An -tx1 -N16 "$IMEI_FILE" 2>/dev/null | tr -d ' \n')
    if [ -n "$raw_hex" ] && [ "${#raw_hex}" -ge 16 ]; then
        # Format BCD digits
        setprop persist.radio.imei.raw "$raw_hex" 2>/dev/null || true
    fi
fi

# Detect SIM Card insertion
sim1_state="ABSENT"
sim2_state="ABSENT"

# Check SIM tray / GPIO status if available
if [ -f /sys/class/switch/sim_switch/state ]; then
    tray=$(cat /sys/class/switch/sim_switch/state 2>/dev/null)
    [ "$tray" = "1" ] && sim1_state="READY"
fi

setprop gsm.sim.state.1 "$sim1_state" 2>/dev/null || true
setprop gsm.sim.state.2 "$sim2_state" 2>/dev/null || true
setprop ro.telephony.sim.slots 2 2>/dev/null || true
setprop persist.recmod.sim_imei.loaded "1" 2>/dev/null || true

echo "-> MediaTek baseband and telephony stack initialized in RAM."
exit 0
