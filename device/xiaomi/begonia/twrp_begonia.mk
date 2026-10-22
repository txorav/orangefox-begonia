#
# Copyright (C) 2022-2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/begonia

# Inherit from the begonia device configuration.
$(call inherit-product, $(DEVICE_PATH)/device.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)

# Inherit OrangeFox and AERA settings when present
$(call inherit-product-if-exists, $(DEVICE_PATH)/fox_begonia.mk)
$(call inherit-product-if-exists, $(DEVICE_PATH)/aera_begonia.mk)

# Inherit common recovery configuration
$(call inherit-product, vendor/twrp/config/common.mk)

# Device identifier. This must come after all inclusions.
PRODUCT_DEVICE := begonia
PRODUCT_NAME := twrp_begonia
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := Redmi Note 8 Pro
PRODUCT_MANUFACTURER := Xiaomi
