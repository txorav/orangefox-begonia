#
# Copyright (C) 2022-2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/twrp_begonia.mk \
    $(LOCAL_DIR)/pb_begonia.mk \
    $(LOCAL_DIR)/fox_begonia.mk \
    $(LOCAL_DIR)/aera_begonia.mk

COMMON_LUNCH_CHOICES := \
    twrp_begonia-eng \
    twrp_begonia-userdebug \
    pb_begonia-eng \
    pb_begonia-userdebug \
    fox_begonia-eng \
    fox_begonia-userdebug \
    aera_begonia-eng \
    aera_begonia-userdebug
