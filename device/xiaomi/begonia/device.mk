#
# Copyright (C) 2022-2026 The Android Open Source Project
# Copyright (C) 2024-2026 The AERA Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Unified partitions: enable dynamic (super/logical) path alongside physical
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# API Level
PRODUCT_SHIPPING_API_LEVEL := 29

# Override vendor security patch level
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.build.security_patch=2099-12-31 \
    ro.bootimage.build.date.utc=0 \
    ro.build.date.utc=0

# Additional target libraries
TARGET_RECOVERY_DEVICE_MODULES += \
    libkeymaster4 \
    libpuresoftkeymasterdevice

TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += \
    $(TARGET_OUT_SHARED_LIBRARIES)/libkeymaster4.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libpuresoftkeymasterdevice.so

AERA_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += \
    $(TARGET_OUT_SHARED_LIBRARIES)/libkeymaster4.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libpuresoftkeymasterdevice.so

PRODUCT_PACKAGES += \
    libshim_beanpod

# Health HAL (needed by decryption bring-up)
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# fastbootd for flashing/erasing dynamic logical partitions
PRODUCT_PACKAGES += \
    fastbootd

# Wi-Fi for AERA PC Connection (wpa_supplicant, wpa_cli + MTK stack)
PRODUCT_PACKAGES += \
    wpa_supplicant \
    wpa_cli

TARGET_RECOVERY_DEVICE_MODULES += \
    wpa_supplicant \
    wpa_cli

TW_RECOVERY_ADDITIONAL_RELINK_BINARY_FILES += \
    $(TARGET_OUT_VENDOR_EXECUTABLES)/hw/wpa_supplicant \
    $(TARGET_OUT_VENDOR_EXECUTABLES)/wpa_cli

AERA_RECOVERY_ADDITIONAL_RELINK_BINARY_FILES += \
    $(TARGET_OUT_VENDOR_EXECUTABLES)/hw/wpa_supplicant \
    $(TARGET_OUT_VENDOR_EXECUTABLES)/wpa_cli

TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/libkeystore-wifi-hidl.so \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/libkeystore-engine-wifi-hidl.so \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/libnl.so \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/libssl.so

AERA_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/libkeystore-wifi-hidl.so \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/libkeystore-engine-wifi-hidl.so \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/libnl.so \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/libssl.so

# curl for downloading files in recovery
ifneq ($(wildcard external/curl/Android.bp),)
TARGET_RECOVERY_DEVICE_MODULES += \
    curl

TW_RECOVERY_ADDITIONAL_RELINK_BINARY_FILES += \
    $(TARGET_OUT_EXECUTABLES)/curl

AERA_RECOVERY_ADDITIONAL_RELINK_BINARY_FILES += \
    $(TARGET_OUT_EXECUTABLES)/curl

TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += \
    $(TARGET_OUT_SHARED_LIBRARIES)/libcrypto.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libz.so

AERA_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += \
    $(TARGET_OUT_SHARED_LIBRARIES)/libcrypto.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libz.so
endif
