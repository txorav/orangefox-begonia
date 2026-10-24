#!/usr/bin/env bash
# ==============================================================================
# OrangeFox Begonia - Addon Packaging Utility
#
# Generates flashable Fox Addon ZIP archives:
#   1) imei_fixer.zip: Begonia Native IMEI Fixer & NVRAM Manager
#   2) pox_logs_dumper.zip: Begonia PoX Diagnostic Logs Dumper
#
# Output targets:
#   - device/xiaomi/begonia/addons/
#   - device/xiaomi/begonia/recovery/root/Fox/FoxFiles/FoxAddons/
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADDONS_SRC="${SCRIPT_DIR}/recovery/root/system/etc/fox_addons"
ADDONS_OUT="${SCRIPT_DIR}/addons"
RECOVERY_ADDONS="${SCRIPT_DIR}/recovery/root/Fox/FoxFiles/FoxAddons"

mkdir -p "${ADDONS_OUT}" "${RECOVERY_ADDONS}"

package_addon() {
    local addon_id="$1"
    local src_dir="${ADDONS_SRC}/${addon_id}"

    if [ ! -d "${src_dir}" ]; then
        echo "[-] Error: Source directory for ${addon_id} not found at ${src_dir}"
        return 1
    fi

    echo "==> Packaging Fox Addon: ${addon_id}..."
    chmod +x "${src_dir}/META-INF/com/google/android/update-binary" 2>/dev/null || true

    local zip_file="${ADDONS_OUT}/${addon_id}.zip"
    rm -f "${zip_file}"

    (cd "${src_dir}" && zip -r9 -X "${zip_file}" addon.prop META-INF)

    # Copy to recovery root so it is automatically included in the recovery ramdisk
    cp "${zip_file}" "${RECOVERY_ADDONS}/${addon_id}.zip"

    echo "    [+] Generated: ${zip_file} ($(ls -lh "${zip_file}" | awk '{print $5}'))"
    echo "    [+] Embedded in ramdisk: ${RECOVERY_ADDONS}/${addon_id}.zip"
}

package_addon "imei_fixer"
package_addon "pox_logs_dumper"

echo ""
echo "==> Fox Addons Packaging Complete!"
