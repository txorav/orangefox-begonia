#!/system/bin/sh
#
# Unified Partition Layout Detection for Redmi Note 8 Pro (begonia / begoniain)
# Automatically detects Dynamic (retrofitted super) vs Non-Dynamic (physical partitions)
#

TAG="detect_layout"
LOG() {
    echo "[$TAG] $1"
    command -v log >/dev/null 2>&1 && log -t "$TAG" "$1"
}

LOG "Starting partition layout detection..."

SYS_BLK=""
for candidate in \
    "/dev/block/platform/bootdevice/by-name/system" \
    "/dev/block/bootdevice/by-name/system" \
    "/dev/block/by-name/system"; do
    if [ -b "$candidate" ] || [ -e "$candidate" ]; then
        SYS_BLK="$candidate"
        break
    fi
done

if [ -z "$SYS_BLK" ]; then
    LOG "Warning: system block device not found; defaulting to dynamic layout."
    IS_DYNAMIC=1
else
    LOG "Found system block device at $SYS_BLK"
    
    # Check for liblp super metadata geometry magic (0x616c4467 -> "gDal" in ASCII at offset 4096)
    MAGIC=$(dd if="$SYS_BLK" bs=1 skip=4096 count=4 2>/dev/null)
    
    # Check for ext4 superblock magic at offset 1080 (offset 1024 + 56 = 0x53 0xEF)
    EXT4_MAGIC=$(dd if="$SYS_BLK" bs=1 skip=1080 count=2 2>/dev/null | od -A n -t x1 2>/dev/null | tr -d ' \n')

    if [ "$MAGIC" = "gDal" ]; then
        LOG "Detected LP_METADATA_GEOMETRY_MAGIC (gDal) at offset 4096 -> Dynamic Partition Layout (super)"
        IS_DYNAMIC=1
    elif [ "$EXT4_MAGIC" = "53ef" ]; then
        LOG "Detected raw ext4 superblock (0x53ef) at offset 1024 -> Non-Dynamic Physical Layout"
        IS_DYNAMIC=0
    else
        # Probing with blkid as secondary check
        BLKID_OUT=$(blkid "$SYS_BLK" 2>/dev/null)
        if echo "$BLKID_OUT" | grep -q 'TYPE="ext4"'; then
            LOG "blkid detected direct ext4 on physical system -> Non-Dynamic Physical Layout"
            IS_DYNAMIC=0
        elif echo "$BLKID_OUT" | grep -q 'TYPE="erofs"'; then
            LOG "blkid detected direct erofs on physical system -> Non-Dynamic Physical Layout"
            IS_DYNAMIC=0
        else
            LOG "No direct filesystem on physical system; defaulting to Dynamic Partition Layout"
            IS_DYNAMIC=1
        fi
    fi
fi

if [ "$IS_DYNAMIC" -eq 1 ]; then
    LOG "Applying DYNAMIC partition layout..."
    [ -f /system/etc/recovery.fstab.dynamic ] && cp -f /system/etc/recovery.fstab.dynamic /system/etc/recovery.fstab
    [ -f /system/etc/twrp.flags.dynamic ] && cp -f /system/etc/twrp.flags.dynamic /system/etc/twrp.flags
    setprop ro.begonia.layout "dynamic"
    setprop ro.boot.dynamic_partitions "true"
else
    LOG "Applying NON-DYNAMIC partition layout..."
    [ -f /system/etc/recovery.fstab.nondynamic ] && cp -f /system/etc/recovery.fstab.nondynamic /system/etc/recovery.fstab
    [ -f /system/etc/twrp.flags.nondynamic ] && cp -f /system/etc/twrp.flags.nondynamic /system/etc/twrp.flags
    setprop ro.begonia.layout "nondynamic"
    setprop ro.boot.dynamic_partitions "false"
fi

LOG "Partition layout configuration applied: $(getprop ro.begonia.layout)"
exit 0
