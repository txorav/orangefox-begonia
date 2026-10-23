# Investigation Report: SHRP & TWRP Decryption Failure Analysis & Fix
**Device:** Xiaomi Redmi Note 8 Pro (`begonia` / `begoniain`)  
**Platform:** MediaTek MT6785 (Helio G90T), Kernel Linux 4.14  
**TEE / Crypto HAL:** Microtrust Beanpod TEE (`teei_daemon`), Keymaster 4.0 (`android.hardware.keymaster@4.0-service.beanpod`), Gatekeeper 1.0  
**Tested Recoveries:** SHRP v3.2_12, TWRP v3.7.1_12 (wuxinG90), PBRP v4.1  
**Target ROM:** Lunaris AOSP Android 16 (`BP4A.251205.006`), stock MIUI 12.5, AOSP/LineageOS  

---

## 1. Executive Summary

Both SHRP and TWRP currently fail to decrypt user data (`/sdcard` / `/data/media/0`) on Redmi Note 8 Pro. 
Hardware TEE communication and Keymaster unwrap **are fully functioning**. The failure is caused by an **fscrypt policy version mismatch** and an incorrect metadata encryption configuration:
1. The ROM encrypts `/data` using **FBE (File-Based Encryption) v1** policies (`aes-256-xts:aes-256-cts:v1`) with 8-byte key descriptors installed into the kernel session keyring.
2. The current `recovery.fstab` files in `device/xiaomi/begonia` only specify `fileencryption=aes-256-xts` (introduced in commit `ab3b186`). In Android 11/12 recovery trees, omitting `:v1` causes TWRP/SHRP's fscrypt parser to default to **fscrypt v2** (`FS_IOC_ADD_ENCRYPTION_KEY` with 16-byte key identifiers).
3. Because the v1 key descriptor (`5e646977405a1d19`) is never inserted into the kernel keyring, `/data/misc` remains un-decrypted (all subdirectories appear as ciphertext strings, e.g. `Cf3LiBAAAAAxe+JQPkigEpx7uiofPOYp`).
4. `fscrypt_init_user0` subsequently attempts to open `/data/misc/vold/user_keys/` and fails with `ENOENT` (`No such file or directory`). User 0's CE key is never unlocked, leaving `/sdcard` completely encrypted.
5. In addition, `BoardConfig.mk` enables `TW_INCLUDE_FBE_METADATA_DECRYPT := true`, forcing Key_Directory to `/metadata/vold/metadata_encryption`, which does not exist on MT6785 devices.

---

## 2. On-Device Evidence & Kernel Forensics

### A. Live Recovery Boot Log (`/tmp/recovery.log` & `logcat`)
During SHRP boot:
```text
beanpodkeymaster: Enter BeanpodKeymaster BeginOperation
beanpodkeymaster: Enter BeanpodKeymaster UpgradeKey
beanpodkeymaster: Enter BeanpodKeymaster UpdateOperation
beanpodkeymaster: Enter BeanpodKeymaster FinishOperation
recovery: Installed fscrypt key with ref d52577374ea2aeddc1ddb4b213465bb5 to /data
recovery: Added fscrypt-provisioning key for d52577374ea2aeddc1ddb4b213465bb5 to session keyring
recovery: fscrypt_init_user0
cutils  : Failed to mkdir(/data/misc/vold/user_keys): No such file or directory
recovery: Failed to prepare /data/misc/vold/user_keys: No such file or directory
```
Notice:
- Keymaster 4.0 Beanpod successfully unpacked the master key.
- Recovery installed `d52577374ea2aeddc1ddb4b213465bb5` (a 16-byte/32-hex character v2 key identifier).
- `fscrypt_init_user0` failed immediately when attempting to create/access `/data/misc/vold/user_keys`.

### B. Encryption Policy Verification (`fscryptpolicyget`)
Querying the directory policies on the target device:
```bash
fscryptpolicyget /data/misc
# Output: 5e646977405a1d19 (16 hex chars = 8 bytes -> fscrypt v1 descriptor)

fscryptpolicyget /data/media/0
# Output: 4462d60873230a44 (16 hex chars = 8 bytes -> fscrypt v1 descriptor)
```

### C. Live Kernel Keyring Inspection (`/proc/keys`)
When inspecting the running, decrypted Android 16 system:
```text
10fb0676 ._fscrypt 5e646977405a1d19  <-- Systemwide DE key (decrypts /data/misc)
2e948d91 ._fscrypt 4462d60873230a44  <-- User 0 CE key (decrypts /data/media/0)
06b126a6 ._fscrypt d961fce07a3b4a8f  <-- User 0 DE key (decrypts /data/user_de/0)
20c8a092 keyring   fscrypt-sdc46: 4   <-- Linked filesystem keyring for userdata
```
The kernel expects **v1 logon keys** (`._fscrypt <8-byte-descriptor>`). Because TWRP/SHRP installed a v2 identifier (`d52577374ea2aeddc1ddb4b213465bb5`), the kernel could not match `5e646977405a1d19`.

### D. Resulting Ciphertext Paths in Recovery
Because `/data/misc` was never decrypted by the kernel, all subdirectories showed up as raw ciphertext:
- `/data/misc/vold` was seen as: `Cf3LiBAAAAAxe+JQPkigEpx7uiofPOYp` (inode 77, `vold_data_file`)
- `/data/misc/keystore` was seen as: `tUkofDAAAAQ9iRuY6ywLicIaESDFha29` (inode 25, `keystore_data_file`)
- `/data/misc/gatekeeper` was seen as: `GeP6uCAAAAgAoobYj23QmM8ef34tthAw` (inode 48, `gatekeeper_data_file`)

Since the path `/data/misc/vold` did not exist in plaintext, `mkdir(/data/misc/vold/user_keys)` returned `ENOENT` (`No such file or directory`), aborting user 0 unlock.

---

## 3. Reverse Engineering Findings: TWRP in `/home/dev/Documents/roms`

The user specifically noted that `TWRP-3.7.1_12-Unified Ver By wuxinG90-20251213-begonia.img` also suffers from this issue.

We unpacked and inspected its ramdisk:
1. **`prop.default` forces v2 globally:**
   ```properties
   ro.crypto.volume.options=::v2
   ro.crypto.dm_default_key.options_format.version=2
   ro.crypto.volume.metadata.method=dm-default-key
   ```
   Setting `ro.crypto.volume.options=::v2` causes TWRP's crypto subsystem to override fstab entries and force v2 key derivation and ioctls.
2. **`merge-fstab.sh` fallback:**
   For non-dynamic ROMs, `merge-fstab.sh` appends `recovery-fbev1.fstab`, which contains:
   ```text
   /dev/block/platform/bootdevice/by-name/userdata /data ext4 ... fileencryption=software
   /dev/block/platform/bootdevice/by-name/userdata /data f2fs ... fileencryption=software
   ```
   `fileencryption=software` is legacy syntax that fails to specify `v1` and falls back to `v2` under `ro.crypto.volume.options=::v2`.

In contrast, the working **PBRP** image (`PBRP-begonia-4.1-20231221-1423-UNOFFICIAL_Beanpod.zip`) uses:
```text
/dev/block/platform/bootdevice/by-name/userdata /data ext4 ... fileencryption=aes-256-xts:aes-256-cts:v1
/dev/block/platform/bootdevice/by-name/userdata /data f2fs ... fileencryption=aes-256-xts:aes-256-cts:v1
```
And does **not** have `ro.crypto.volume.options=::v2` in `prop.default`.

---

## 4. Installed ROM Reference Configuration

Checking `/vendor/etc/fstab.mt6785` from the ROM currently running on the device:
```text
/dev/block/platform/bootdevice/by-name/userdata   /data       ext4     noatime,nosuid,nodev,noauto_da_alloc,errors=panic,inlinecrypt wait,check,formattable,quota,latemount,reservedsize=128m,fileencryption=aes-256-xts:aes-256-cts:v1,fsverity
/dev/block/platform/bootdevice/by-name/userdata   /data       f2fs     noatime,nosuid,nodev,discard,flush_merge,reserve_root=134217,resgid=1065,alloc_mode=reuse,fsync_mode=nobarrier,inlinecrypt wait,check,formattable,quota,latemount,reservedsize=128m,fileencryption=aes-256-xts:aes-256-cts:v1,fsverity
/dev/block/platform/bootdevice/by-name/metadata   /metadata   ext4     noatime,nosuid,nodev,discard wait,data=journal,commit=1,check,formattable,first_stage_mount
```
Note:
- Encryption flag: `fileencryption=aes-256-xts:aes-256-cts:v1`
- There is **no** `keydirectory=/metadata/vold/metadata_encryption` (pure FBE, no metadata encryption).

---

## 5. Required Fixes & Implementation Plan

To fix decryption across all trees (`aera`, `shrp-begonia`, `twrp-begonia`, `orangefox-begonia`, `pbrp-begonia`):

### 1. Fix `recovery.fstab`, `recovery.fstab.nondynamic`, and `recovery.fstab.dynamic`
Update the `/data` entries in all three files to explicitly declare `:aes-256-cts:v1`:
```fstab
/dev/block/platform/bootdevice/by-name/userdata  /data                 ext4     noatime,nosuid,nodev,noauto_da_alloc,errors=panic               wait,check,formattable,quota,resize,reservedsize=128m,fileencryption=aes-256-xts:aes-256-cts:v1
/dev/block/platform/bootdevice/by-name/userdata  /data                 f2fs     noatime,nosuid,nodev,discard                                    wait,check,formattable,quota,resize,reservedsize=128m,fileencryption=aes-256-xts:aes-256-cts:v1
```

### 2. Update `BoardConfig.mk`
Disable `TW_INCLUDE_FBE_METADATA_DECRYPT`:
```makefile
# Crypto & Decryption
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
BOARD_USES_METADATA_PARTITION := true
# Begonia MT6785 uses pure FBE v1 without dm-crypt metadata encryption
TW_INCLUDE_FBE_METADATA_DECRYPT := false
AERA_INCLUDE_CRYPTO := true
```

### 3. Ensure `prop.default` / `system.prop` Does Not Force `::v2`
Ensure neither `system.prop` nor `vendor.prop` sets:
```properties
# DO NOT SET: ro.crypto.volume.options=::v2
```
Only keep:
```properties
ro.crypto.volume.filenames_mode=aes-256-cts
```

### 4. Ensure `detect_partition_layout.sh` Preserves `:v1`
Verify that `detect_partition_layout.sh` copies the updated fstabs (`recovery.fstab.dynamic` or `recovery.fstab.nondynamic`) without stripping the `:v1` parameter.

---

## 6. Verification Steps for Next Agent

1. Apply the edits above to `device/xiaomi/begonia/`.
2. Build the recovery image (e.g. using `python3 /media/dev/3A3E549FFDB4573D/twrp/build/build_shrp.py` or Android build environment).
3. Boot the recovery on the connected device:
   ```bash
   adb reboot bootloader
   fastboot boot <path_to_built_recovery.img>
   ```
4. Verify in `adb shell /tmp/recovery.log` that:
   - Keymaster derives the v1 key descriptor `5e646977405a1d19`.
   - `/data/misc/vold/user_keys` is successfully read.
   - User 0 CE key `4462d60873230a44` is installed.
   - `/sdcard` displays decrypted folder names (`DCIM`, `Download`, `Documents`, etc.).
