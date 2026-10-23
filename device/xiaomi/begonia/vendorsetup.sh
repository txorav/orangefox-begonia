#!/bin/bash
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

FDEVICE="begonia"

aera_get_target_device() {
	local script_path
	script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
	if echo "$script_path" | grep -q "/$FDEVICE$"; then
		AERA_BUILD_DEVICE="$FDEVICE"
	elif echo "$0" | grep -q "$FDEVICE"; then
		AERA_BUILD_DEVICE="$FDEVICE"
	fi
}

if [ -z "$AERA_BUILD_DEVICE" ]; then
	aera_get_target_device
fi

if [ "$1" = "$FDEVICE" ] || [ "$AERA_BUILD_DEVICE" = "$FDEVICE" ] || [ "$FOX_BUILD_DEVICE" = "$FDEVICE" ] || [ -n "$(echo "$BASH_SOURCE" | grep "$FDEVICE")" ]; then
	export LC_ALL="C"
	export AERA_PRODUCT_PREFIX=AERA
	export AERA_BUILD_STATUS=Unofficial
	export AERA_BUILD_TYPE=Beta
	export AERA_VANILLA_BUILD=1

	# Device identity: Redmi Note 8 Pro (begonia / begoniain)
	# Non-A/B system-as-root with dedicated recovery partition.
	# Unified partition support (physical by-name or retrofitted super/dynamic).
	export TARGET_DEVICE_ALT="begonia,begoniain"
	export AERA_TARGET_DEVICES="$TARGET_DEVICE_ALT"
	export FOX_TARGET_DEVICES="$TARGET_DEVICE_ALT"

	# OrangeFox specific settings
	export FOX_BUILD_DEVICE="begonia"
	export OF_MAINTAINER="txorav"
	export OF_SCREEN_H=2340
	export OF_STATUS_H=80
	export OF_STATUS_INDENT_LEFT=64
	export OF_STATUS_INDENT_RIGHT=48
	export OF_HIDE_NOTCH=1
	export OF_CLOCK_POS=1
	export OF_OPTIONS_LIST_NUM=12
	export OF_ALLOW_DISABLE_NAVBAR=1
	export OF_SPLASH_MAX_SIZE=4096
	export TARGET_SCREEN_WIDTH=1080
	export TARGET_SCREEN_HEIGHT=2340
	export OF_USE_GREEN_LED=0
	export OF_FLASHLIGHT_ENABLE=1
	export OF_FL_PATH1="/sys/class/leds/flashlight/brightness"
	export OF_FL_PATH2="/sys/class/leds/torch-light0/brightness"
	export OF_FLASHLIGHT_MAX_BRIGHTNESS=255
	export OF_THEME_DARK=1
	export OF_ENABLE_THEME_ENGINE=1
	export OF_QUICK_BACKUP_LIST="/boot;/data;"
	export OF_ENABLE_LPTOOLS=1
	export OF_ENABLE_ALL_PARTITION_TOOLS=1
	export OF_USE_DMCTL=1
	export OF_USE_MAGISKBOOT=1
	export OF_USE_MAGISKBOOT_FOR_ALL_PATCHES=1
	export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1
	export FOX_USE_BASH_SHELL=1
	export FOX_ASH_IS_BASH=1
	export FOX_USE_NANO_EDITOR=1
	export FOX_USE_SED_BINARY=1
	export FOX_USE_TAR_BINARY=1
	export OF_SKIP_MULTIUSER_FOLDERS_BACKUP=1
	export FOX_DELETE_AROMAFM=1
	export FOX_ENABLE_APP_MANAGER=1
	export OF_DONT_PATCH_ENCRYPTED_DEVICE=1
	export OF_NO_MIUI_PATCH_WARNING=1
	export OF_NO_TREBLE_COMPATIBILITY_CHECK=1
	export OF_UNBIND_SDCARD_F2FS=1
	export OF_PATCH_AVB20=1
	export OF_DEFAULT_KEYMASTER_VERSION="4.0"
	export TW_FORCE_KEYMASTER_VER=true
	export OF_FBE_METADATA_MOUNT_IGNORE=1
	export OF_FIX_DECRYPTION_ON_DATA_MEDIA=1

	# Tools and utilities
	export AERA_USE_BASH_SHELL=1
	export AERA_USE_TAR_BINARY=1
	export AERA_USE_SED_BINARY=1
	export AERA_USE_LZ4_BINARY=1
	export AERA_USE_ZSTD_BINARY=1
	export AERA_USE_DATE_BINARY=1
	export AERA_USE_GREP_BINARY=1
	export AERA_USE_BUSYBOX_BINARY=1
	export AERA_USE_XZ_UTILS=1
	export AERA_USE_NANO_EDITOR=1
	export AERA_DELETE_AROMAFM=1
	export AERA_DELETE_MAGISK_ADDON=1
	export AERA_USE_UPDATED_MAGISKBOOT=1
	export AERA_USE_FSCK_EROFS_BINARY=1
	export AERA_USE_PATCHELF_BINARY=1

	# Root Manager integration (KernelSU / KernelSU Next / SukiSU Ultra)
	export AERA_ENABLE_ROOT_MANAGER=1

	# Settings and storage directories
	export AERA_SETTINGS_ROOT_DIRECTORY=/data/recovery
	export AERA_MISCELLANEOUS_ROOT_DIRECTORY=/sdcard
	export AERA_ALLOW_EARLY_SETTINGS_LOAD=1

	# Compression: Helio G90T 4.14 kernel decompressor only supports gzip ramdisk.
	# Keep LZ4 compression disabled for ramdisk packaging.
	export AERA_USE_LZ4_COMPRESSION=0

	# AERA starts at R1.0; do not append legacy variant or patch suffixes.
	unset AERA_VARIANT
	unset AERA_MAINTAINER_PATCH_VERSION
fi
