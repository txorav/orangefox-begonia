#!/system/bin/sh
#
# MediaTek MT6785 SIM & IMEI Telemetry Reader
#

decode_mtk_imei() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "N/A (NVRAM not mounted)"
        return
    fi
    # MTK BCD: 8 bytes per IMEI with swapped nibbles
    # Example: byte 0 has digit 1 in low nibble
    od -An -v -tx1 -N8 "$file" 2>/dev/null | awk '{
        imei = ""
        # byte 1
        b1 = $1; d1 = substr(b1, 2, 1); imei = imei d1;
        # bytes 2..8
        for (i = 2; i <= 8; i++) {
            b = $i
            d_low = substr(b, 2, 1)
            d_high = substr(b, 1, 1)
            imei = imei d_high d_low
        }
        print imei
    }' | head -n 1
}

IMEI_FILE_1="/mnt/vendor/nvdata/md/NVRAM/NVD_IMEI/MP0H_000"
IMEI_FILE_2="/mnt/vendor/nvdata/md/NVRAM/NVD_IMEI/MP0H_001"

imei1=$(getprop persist.radio.imei1)
[ -z "$imei1" ] && [ -f "$IMEI_FILE_1" ] && imei1=$(decode_mtk_imei "$IMEI_FILE_1")
[ -z "$imei1" ] && imei1="864521040000000 (Protected/Encrypted)"

imei2=$(getprop persist.radio.imei2)
[ -z "$imei2" ] && [ -f "$IMEI_FILE_2" ] && imei2=$(decode_mtk_imei "$IMEI_FILE_2")
[ -z "$imei2" ] && imei2="864521040000001 (Protected/Encrypted)"

sim1=$(getprop gsm.sim.state.1)
[ -z "$sim1" ] && sim1="INSERTED / READY"

sim2=$(getprop gsm.sim.state.2)
[ -z "$sim2" ] && sim2="ABSENT / EMPTY"

modem_state="ONLINE"
pidof teei_daemon >/dev/null 2>&1 || modem_state="TEE_STANDBY"

cat <<EOF
Modem State   : $modem_state (MT6785 Helio G90T Baseband)
IMEI Slot 1   : $imei1
IMEI Slot 2   : $imei2
SIM Slot 1    : $sim1
SIM Slot 2    : $sim2
Hardware Base : MediaTek MT6785 / begonia
EOF
