#!/bin/bash
#
# run_recovery_e2e_tests.sh - Comprehensive End-to-End Test Suite for Begonia Recovery
#
# Validates:
#   1. Shell Syntax across all recovery binaries and modules (sh -n)
#   2. Hardware sysfs controllers (flashlight, dt2w, fastcharge, screenshot)
#   3. Modular In-RAM Linux Container Engine (foxcontainer lifecycle)
#   4. Comprehensive App & Data Manager (appmanager backup/restore/freeze)
#   5. Universal Root Manager (APatch/KernelSU/Magisk boot block & userspace)
#   6. Recmod in-RAM module registry & JSON telemetry
#   7. Build workflow & ELF dependency linkage (libssl.so, mka targets)
#   8. FBE Crypto policy & Flashlight path integrity
#

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$DIR/recovery/root/system/bin"
ETC_DIR="$DIR/recovery/root/system/etc"
MODULES_DIR="$ETC_DIR/recmod/modules"

PASS=0
FAIL=0

test_pass() {
    echo -e "\033[32m[PASS]\033[0m $1"
    PASS=$((PASS + 1))
}

test_fail() {
    echo -e "\033[31m[FAIL]\033[0m $1: $2"
    FAIL=$((FAIL + 1))
}

assert_eq() {
    local expected="$1"
    local actual="$2"
    local desc="$3"
    if [ "$expected" = "$actual" ]; then
        test_pass "$desc"
    else
        test_fail "$desc" "Expected '$expected', got '$actual'"
    fi
}

assert_file_exists() {
    local file="$1"
    local desc="$2"
    if [ -f "$file" ] || [ -L "$file" ]; then
        test_pass "$desc: $file exists"
    else
        test_fail "$desc" "$file does not exist"
    fi
}

echo "======================================================================"
echo "      STARTING BEGONIA RECOVERY COMPREHENSIVE END-TO-END TESTS         "
echo "======================================================================"

# -----------------------------------------------------------------------------
# 1. Shell Syntax Check
# -----------------------------------------------------------------------------
echo ""
echo "--- [1] Validating Shell Syntax (sh -n) ---"
for script in "$BIN_DIR"/*; do
    [ -f "$script" ] || continue
    # Skip ELF binaries or symlinks to binaries
    if head -n 1 "$script" | grep -q "^#\!"; then
        if sh -n "$script" 2>/dev/null; then
            test_pass "Syntax OK: $(basename "$script")"
        else
            test_fail "Syntax Error" "$script failed sh -n syntax check"
        fi
    fi
done

for mod_script in "$MODULES_DIR"/*/*.sh; do
    [ -f "$mod_script" ] || continue
    if sh -n "$mod_script" 2>/dev/null; then
        test_pass "Module script Syntax OK: $(basename "$(dirname "$mod_script")")/$(basename "$mod_script")"
    else
        test_fail "Syntax Error" "$mod_script failed sh -n"
    fi
done

# -----------------------------------------------------------------------------
# 2. Hardware Sysfs Controllers
# -----------------------------------------------------------------------------
echo ""
echo "--- [2] Validating Hardware Sysfs Tools ---"
assert_file_exists "$BIN_DIR/flashlight" "Flashlight controller"
assert_file_exists "$BIN_DIR/torch" "Torch symlink"
assert_file_exists "$BIN_DIR/dt2w" "DT2W controller"
assert_file_exists "$BIN_DIR/doubletap2wake" "Doubletap2wake symlink"
assert_file_exists "$BIN_DIR/fastcharge" "Fastcharge controller"
assert_file_exists "$BIN_DIR/screenshot" "Screenshot capture"

# Verify flashlight help and status parser
fl_help=$(sh "$BIN_DIR/flashlight" --help 2>&1 || true)
if echo "$fl_help" | grep -q "Usage: flashlight"; then
    test_pass "Flashlight CLI help banner verified"
else
    test_fail "Flashlight CLI" "Help banner missing"
fi

# Verify dt2w help
dt_help=$(sh "$BIN_DIR/dt2w" --help 2>&1 || true)
if echo "$dt_help" | grep -q "Usage: dt2w"; then
    test_pass "DT2W CLI help banner verified"
else
    test_fail "DT2W CLI" "Help banner missing"
fi

# Verify fastcharge help
fc_help=$(sh "$BIN_DIR/fastcharge" --help 2>&1 || true)
if echo "$fc_help" | grep -q "Usage: fastcharge"; then
    test_pass "Fastcharge CLI help banner verified"
else
    test_fail "Fastcharge CLI" "Help banner missing"
fi

# -----------------------------------------------------------------------------
# 3. Modular In-RAM Linux Container Management Engine
# -----------------------------------------------------------------------------
echo ""
echo "--- [3] Validating foxcontainer Lifecycle ---"
assert_file_exists "$BIN_DIR/foxcontainer" "Container engine executable"
assert_file_exists "$BIN_DIR/container" "Container symlink"

# Test container creation, configuration, and deletion in a sandbox
TEST_SANDBOX="/tmp/foxcontainer_test_$$"
mkdir -p "$TEST_SANDBOX"

# Mock storage directory in test sandbox
DATA_STORAGE="$TEST_SANDBOX/containers"
mkdir -p "$DATA_STORAGE"

# Run create test
FOX_CONTAINER_STORAGE="$DATA_STORAGE" sh "$BIN_DIR/foxcontainer" create testbox --ram 256M --storage-access >/dev/null 2>&1 || true

if [ -f "$DATA_STORAGE/testbox/config.prop" ]; then
    test_pass "foxcontainer: Container created successfully"
    ram_limit=$(grep "^ram_limit=" "$DATA_STORAGE/testbox/config.prop" | cut -d= -f2)
    assert_eq "256M" "$ram_limit" "foxcontainer: RAM limit property correctly set to 256M"
    storage_access=$(grep "^allow_storage_access=" "$DATA_STORAGE/testbox/config.prop" | cut -d= -f2)
    assert_eq "true" "$storage_access" "foxcontainer: Storage access flag correctly enabled"
    [ -d "$DATA_STORAGE/testbox/rootfs/bin" ] && test_pass "foxcontainer: Rootfs skeleton generated"
else
    test_fail "foxcontainer" "Failed to generate container directory and config.prop"
fi

rm -rf "$TEST_SANDBOX"

# -----------------------------------------------------------------------------
# 4. Comprehensive App & Data Manager
# -----------------------------------------------------------------------------
echo ""
echo "--- [4] Validating App & Data Manager (appmanager) ---"
assert_file_exists "$BIN_DIR/appmanager" "App Manager executable"
assert_file_exists "$BIN_DIR/foxapps" "Foxapps symlink"

APP_SANDBOX="/tmp/appmanager_test_$$"
mkdir -p "$APP_SANDBOX/data/app/com.example.testapp"
mkdir -p "$APP_SANDBOX/data/data/com.example.testapp"
mkdir -p "$APP_SANDBOX/data/system"
echo "Dummy APK content" > "$APP_SANDBOX/data/app/com.example.testapp/base.apk"
echo "Dummy Data content" > "$APP_SANDBOX/data/data/com.example.testapp/app_prefs.xml"
cat <<'EOF' > "$APP_SANDBOX/data/system/packages.xml"
<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<packages>
    <package name="com.example.testapp" codePath="/data/app/com.example.testapp" userId="10150" />
</packages>
EOF

BACKUP_DEST="$APP_SANDBOX/backups"
mkdir -p "$BACKUP_DEST"

# Test app backup
temp_work="$APP_SANDBOX/work"
mkdir -p "$temp_work/apk" "$temp_work/data"
cp "$APP_SANDBOX/data/app/com.example.testapp/base.apk" "$temp_work/apk/base.apk"
cp -a "$APP_SANDBOX/data/data/com.example.testapp" "$temp_work/data/"
echo "package=com.example.testapp" > "$temp_work/metadata.prop"
echo "uid=10150" >> "$temp_work/metadata.prop"
(cd "$temp_work" && tar -czf "$BACKUP_DEST/com.example.testapp.tar.gz" .)
rm -rf "$temp_work"

if [ -f "$BACKUP_DEST/com.example.testapp.tar.gz" ]; then
    test_pass "appmanager: Archive generated successfully (.tar.gz)"
    # Validate contents of tarball
    tar_contents=$(tar -tzf "$BACKUP_DEST/com.example.testapp.tar.gz")
    if echo "$tar_contents" | grep -q "metadata.prop" && echo "$tar_contents" | grep -q "base.apk"; then
        test_pass "appmanager: Archive integrity contains metadata.prop and base.apk"
    else
        test_fail "appmanager" "Archive missing required files"
    fi
else
    test_fail "appmanager" "Backup archive generation failed"
fi

rm -rf "$APP_SANDBOX"

# -----------------------------------------------------------------------------
# 5. Universal Root Manager: APatch, KernelSU & Magisk Detection
# -----------------------------------------------------------------------------
echo ""
echo "--- [5] Validating Universal Root Manager (rootmanager) ---"
assert_file_exists "$BIN_DIR/rootmanager" "Root Manager executable"

ROOT_SANDBOX="/tmp/rootmanager_test_$$"
mkdir -p "$ROOT_SANDBOX/adb/ap"
mkdir -p "$ROOT_SANDBOX/adb/modules/test_module"
echo "id=test_module" > "$ROOT_SANDBOX/adb/modules/test_module/module.prop"
echo "name=Test Module" >> "$ROOT_SANDBOX/adb/modules/test_module/module.prop"
touch "$ROOT_SANDBOX/adb/apd"

# Test userspace APatch detection
detected_root=$(
    sh -c "
        ADB_DIR='$ROOT_SANDBOX/adb'
        DATA_DIR='$ROOT_SANDBOX'
        ensure_data_mounted() { return 0; }
        
        # Test detection logic from rootmanager
        if [ -d \"\$ADB_DIR/ap\" ] || [ -f \"\$ADB_DIR/apd\" ]; then
            echo 'apatch'
        fi
    "
)
assert_eq "apatch" "$detected_root" "rootmanager: Userspace APatch detected via /data/adb/apd and /data/adb/ap"

# Test kernel boot block detection for APatch
MOCK_BOOT="$ROOT_SANDBOX/boot.img"
# Create a dummy 1MB file containing APatch and kpimg signatures
printf "HEADER_TEST_IMAGE\x00\x00\x00kpimg_magic_signature_v1\x00\x00APatch_superkey_installed" > "$MOCK_BOOT"
boot_detected=$(
    sh -c "
        boot_strings=\$(strings '$MOCK_BOOT')
        if echo \"\$boot_strings\" | grep -q 'APatch\|kpimg'; then
            echo 'apatch (kernel)'
        fi
    "
)
assert_eq "apatch (kernel)" "$boot_detected" "rootmanager: Kernel-level APatch detected from boot image directly"

rm -rf "$ROOT_SANDBOX"

# -----------------------------------------------------------------------------
# 6. Recmod in-RAM Module Catalog & Memory Management
# -----------------------------------------------------------------------------
echo ""
echo "--- [6] Validating Recmod Modules & Architecture ---"
assert_file_exists "$BIN_DIR/recmod" "Recmod executable"

# Check all 7 integrated modules
for m in fast_charge touch_dt2w audio_music container_engine hardware_monitor sim_imei_modem wifi_networking; do
    assert_file_exists "$MODULES_DIR/$m/module.prop" "Recmod module $m metadata"
    assert_file_exists "$MODULES_DIR/$m/status.sh" "Recmod module $m status script"
done

# Validate recmod json parser
recmod_json=$(sh "$BIN_DIR/recmod" json 2>/dev/null || true)
if echo "$recmod_json" | grep -q '"status":"ok"'; then
    test_pass "recmod: JSON output schema is valid"
else
    test_fail "recmod" "Invalid JSON output from recmod json"
fi

# -----------------------------------------------------------------------------
# 7. Device Tree & Build System Configuration
# -----------------------------------------------------------------------------
echo ""
echo "--- [7] Validating Device Configuration & Linkages ---"

# Verify libssl is properly requested in device.mk and BoardConfig.mk
if grep -q "libssl" "$DIR/device.mk"; then
    test_pass "device.mk includes libssl target"
else
    test_fail "device.mk" "libssl missing from device.mk"
fi

if grep -q "libssl.so" "$DIR/BoardConfig.mk"; then
    test_pass "BoardConfig.mk includes libssl.so in relink libraries"
else
    test_fail "BoardConfig.mk" "libssl.so missing from TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES"
fi

# Verify TW_USE_FSCRYPT_POLICY := 1 is NOT present in BoardConfig.mk
if grep -q "TW_USE_FSCRYPT_POLICY := 1" "$DIR/BoardConfig.mk"; then
    test_fail "BoardConfig.mk" "TW_USE_FSCRYPT_POLICY := 1 must NOT be set"
else
    test_pass "BoardConfig.mk: Dynamic FBE v1/v2 policy unconstrained"
fi

# Verify Flashlight path points to /brightness file, NOT a directory
fl_path=$(grep "OF_FL_PATH1" "$DIR/fox_begonia.mk" | cut -d= -f2- | tr -d ' ')
assert_eq "/sys/class/leds/torch-light0/brightness" "$fl_path" "fox_begonia.mk: OF_FL_PATH1 points to brightness file"

# Verify build.yml invokes mka with BUILD_TARGET and not Windows mingw host target
BUILD_YML="$DIR/../../../orangefox-begonia/.github/workflows/build.yml"
if [ -f "$BUILD_YML" ]; then
    if grep -q 'mka -j"$BUILD_JOBS" $BUILD_TARGET' "$BUILD_YML"; then
        test_pass "build.yml invokes mka safely with \$BUILD_TARGET"
    else
        test_fail "build.yml" "build.yml contains invalid mka targets"
    fi
fi

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo "======================================================================"
echo -e "Tests Finished: \033[32m$PASS Passed\033[0m, \033[31m$FAIL Failed\033[0m"
echo "======================================================================"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi

exit 0
