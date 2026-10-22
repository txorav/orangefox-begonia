#!/system/bin/sh
#
# MediaTek MT6785 SIM & IMEI Baseband Stack Unloader
#

echo "-> Stopping telephony background daemons..."
setprop persist.recmod.sim_imei.loaded "0" 2>/dev/null || true

# Unmount NV partitions
umount /mnt/vendor/nvdata 2>/dev/null || true
umount /mnt/vendor/nvcfg 2>/dev/null || true
umount /mnt/vendor/protect_f 2>/dev/null || true
umount /mnt/vendor/protect_s 2>/dev/null || true

echo "-> Telephony stack unloaded from RAM."
exit 0
