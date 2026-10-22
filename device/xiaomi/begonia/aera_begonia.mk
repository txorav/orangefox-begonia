#
# Copyright (C) 2024-2026 The AERA Recovery Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Inherit baseline OrangeFox product settings if present
$(call inherit-product-if-exists, $(LOCAL_PATH)/fox_begonia.mk)

# AERA maintainer info
AERA_MAINTAINER := Sai Krishna & contributors

# Screen settings (Begonia physical resolution is 1080x2340)
AERA_SCREEN_H := 2340
AERA_STATUS_H := 80
AERA_HIDE_NOTCH := 1
AERA_CLOCK_POS := 1
AERA_STATUS_INDENT_LEFT := 64
AERA_STATUS_INDENT_RIGHT := 48
AERA_OPTIONS_LIST_NUM := 12
AERA_USE_GREEN_LED := 0
AERA_USE_LOCKSCREEN_BUTTON := 1

# Partition and storage tools
AERA_ENABLE_ALL_PARTITION_TOOLS := 1
AERA_ENABLE_LPTOOLS := 1
AERA_UNBIND_SDCARD_F2FS := 1
AERA_WIPE_METADATA_AFTER_DATAFORMAT := 1
AERA_DYNAMIC_FULL_SIZE := 5364514816
AERA_DISPLAY_FORMAT_FILESYSTEMS_DEBUG_INFO := 1
AERA_QUICK_BACKUP_LIST := /boot;/data;

# Kernel & decryption handling
AERA_FORCE_PREBUILT_KERNEL := 1
AERA_NO_RELOAD_AFTER_DECRYPTION := 1
AERA_NO_TREBLE_COMPATIBILITY_CHECK := 1
AERA_ENABLE_FRP_WIPE := 1
AERA_ENABLE_ROOT_MANAGER := 1

# Compression: MT6785 4.14 kernel decompressor requires gzip ramdisk
AERA_USE_LZ4_COMPRESSION := 0

# Network and PC connection over WLAN
AERA_ENABLE_WLAN := 1
