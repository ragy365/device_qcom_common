# Copyright 2021 Paranoid Android
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

QCOM_COMMON_PATH := device/qcom/common

ifeq ($(TARGET_BOARD_PLATFORM),)
$(error "TARGET_BOARD_PLATFORM is not defined yet, please define in your device makefile so it's accessible to QCOM common.")
endif

# List of QCOM targets.
MSMSTEPPE := sm6150
TRINKET := trinket

QCOM_BOARD_PLATFORMS += \
    $(MSMSTEPPE) \
    $(TRINKET) \
    apq8084 \
    apq8098_latv \
    atoll \
    bengal \
    holi \
    kona \
    lahaina \
    lito \
    mpq8092 \
    msm8226 \
    msm8610 \
    msm8909 \
    msm8909_512 \
    msm8916 \
    msm8916_32 \
    msm8916_32_512 \
    msm8916_64 \
    msm8937 \
    msm8952 \
    msm8953 \
    msm8974 \
    msm8992 \
    msm8994 \
    msm8996 \
    msm8998 \
    msmnile \
    msmnile_au \
    msm_bronze \
    qcs605 \
    sdm660 \
    sdm710 \
    sdm845

# List of targets that use video hardware.
MSM_VIDC_TARGET_LIST := \
    $(MSMSTEPPE) \
    $(TRINKET) \
    apq8084 \
    apq8098_latv \
    atoll \
    kona \
    lito \
    msm8226 \
    msm8610 \
    msm8909 \
    msm8916 \
    msm8937 \
    msm8952 \
    msm8953 \
    msm8974 \
    msm8992 \
    msm8994 \
    msm8996 \
    msm8998 \
    msmnile \
    qcs605 \
    sdm660 \
    sdm710 \
    sdm845

# List of targets that use master side content protection.
MASTER_SIDE_CP_TARGET_LIST := \
    $(MSMSTEPPE) \
    $(TRINKET) \
    apq8098_latv \
    atoll \
    bengal \
    kona \
    lito \
    msm8996 \
    msm8998 \
    msmnile \
    qcs605 \
    sdm660 \
    sdm710 \
    sdm845

# Include QCOM board utilities.
include $(QCOM_COMMON_PATH)/utils.mk

# Kernel Families
5_4_FAMILY := \
    holi \
    lahaina

4_19_FAMILY := \
    bengal \
    kona \
    lito

4_14_FAMILY := \
    $(MSMSTEPPE) \
    $(TRINKET) \
    atoll \
    msmnile \
    msmnile_au

4_9_FAMILY := \
    msm8953 \
    qcs605 \
    sdm710 \
    sdm845

4_4_FAMILY := \
    msm8998 \
    sdm660

3_18_FAMILY := \
    msm8937 \
    msm8996

ifeq ($(call is-board-platform-in-list,$(5_4_FAMILY)),true)
TARGET_KERNEL_VERSION ?= 5.4
TARGET_HALS_VARIANT ?= sm8350
else ifeq ($(call is-board-platform-in-list,$(4_9_FAMILY)),true)
TARGET_KERNEL_VERSION ?= 4.9
TARGET_HALS_VARIANT ?= sdm845
else ifeq ($(call is-board-platform-in-list,$(4_4_FAMILY)),true)
TARGET_KERNEL_VERSION ?= 4.4
TARGET_HALS_VARIANT ?= msm8998
else ifeq ($(call is-board-platform-in-list,$(3_18_FAMILY)),true)
TARGET_KERNEL_VERSION ?= 3.18
TARGET_HALS_VARIANT ?= msm8996
endif

# Override Hals
ifeq ($(TARGET_USE_SM8150_HALS),true)
TARGET_KERNEL_VERSION ?= 4.14
TARGET_HALS_VARIANT ?= sm8150
else ifeq ($(TARGET_USE_SM8250_HALS),true)
TARGET_KERNEL_VERSION ?= 4.19
TARGET_HALS_VARIANT ?= sm8250-common
endif

TARGET_HALS_PATH ?= hardware/qcom-caf/$(TARGET_HALS_VARIANT)

ifeq ($(call is-board-platform-in-list,$(QCOM_BOARD_PLATFORMS)),true)
TARGET_FWK_SUPPORTS_FULL_VALUEADDS ?= true

ifeq ($(TARGET_FWK_SUPPORTS_FULL_VALUEADDS),true)
# Compatibility matrix
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    $(QCOM_COMMON_PATH)/vendor_framework_compatibility_matrix.xml

PRODUCT_VENDOR_PROPERTIES += ro.vendor.qti.va_aosp.support=1
PRODUCT_ODM_PROPERTIES += ro.vendor.qti.va_odm.support=1
endif

# Components
include $(QCOM_COMMON_PATH)/components.mk

# Filesystem
TARGET_FS_CONFIG_GEN += $(QCOM_COMMON_PATH)/config.fs

# Power
TARGET_PROVIDES_POWERHAL := true
ifneq ($(TARGET_PROVIDES_POWERHAL),true)
$(call inherit-product-if-exists, vendor/qcom/opensource/power/power-vendor-product.mk)
endif

# Public Libraries
PRODUCT_COPY_FILES += \
    $(QCOM_COMMON_PATH)/system/public.libraries.system_ext-qti.txt:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/public.libraries-qti.txt

# SECCOMP Extensions
PRODUCT_COPY_FILES += \
    $(QCOM_COMMON_PATH)/vendor/seccomp/codec2.software.ext.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/codec2.software.ext.policy \
    $(QCOM_COMMON_PATH)/vendor/seccomp/codec2.vendor.ext.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/codec2.vendor.ext.policy \
    $(QCOM_COMMON_PATH)/vendor/seccomp/mediacodec-seccomp.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediacodec.policy \
    $(QCOM_COMMON_PATH)/vendor/seccomp/mediaextractor-seccomp.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediaextractor.policy

# Permissions
PRODUCT_COPY_FILES += \
    $(QCOM_COMMON_PATH)/permissions/privapp-permissions-qti.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-qti.xml \
    $(QCOM_COMMON_PATH)/permissions/privapp-permissions-hotword.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-hotword.xml \
    $(QCOM_COMMON_PATH)/permissions/qti_whitelist.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/qti_whitelist.xml

# HIDL
PRODUCT_PACKAGES += \
    android.hidl.base@1.0 \
    android.hidl.base@1.0_system \
    android.hidl.base@1.0.vendor \
    android.hidl.manager@1.0 \
    android.hidl.manager@1.0_system \
    android.hidl.manager@1.0.vendor \
    libhidltransport.vendor \
    libhwbinder.vendor

# Neural Network
PRODUCT_PACKAGES += \
    libprotobuf-cpp-full-rtti

# QTI framework detect
PRODUCT_PACKAGES += \
    libvndfwk_detect_jni.qti \
    libqti_vndfwk_detect \
    libvndfwk_detect_jni.qti.vendor \
    libqti_vndfwk_detect.vendor \
    libqti_vndfwk_detect_system \
    libqti_vndfwk_detect_vendor \
    libvndfwk_detect_jni.qti_system \
    libvndfwk_detect_jni.qti.vendor \

# Telephony - AOSP
PRODUCT_PACKAGES += \
    Stk
    
# Vendor Service Manager
PRODUCT_PACKAGES += \
    vndservicemanager

endif # QCOM_BOARD_PLATFORMS
