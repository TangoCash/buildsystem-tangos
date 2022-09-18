#
# KERNEL
#
KERNEL_VER             = 5.15.0
KERNEL_SOURCE_VER      = 5.15
KERNEL_TYPE            = osmio4kplus
KERNEL_SRC             = linux-edision-$(KERNEL_SOURCE_VER).tar.gz
KERNEL_URL             = http://source.mynonpublic.com/edision
KERNEL_CONFIG          = defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-brcmstb-$(KERNEL_SOURCE_VER)
KERNEL_IMAGE           = zImage
KERNEL_DTB_VER         =

KERNEL_PATCHES = 

#
# DRIVER
#

DRIVER_DATE = 20211228
DRIVER_VER  = $(KERNEL_VER)-$(DRIVER_DATE)
LIBGLES_VER = 2.0

# others
CAIRO_OPTS =

#LINKS_PATCH_BOXTYPE = links-$(LINKS_VER)-event1-input.patch

CUSTOM_RCS     =
CUSTOM_INITTAB =

# release target
neutrino-release-osmio4kplus:
	cp -rf $(SKEL_ROOT)/firmware/availink $(RELEASE_DIR)/lib/firmware
	install -m 0755 $(SKEL_ROOT)/etc/init.d/mmcblk1-by-name $(RELEASE_DIR)/etc/init.d/mmcblk-by-name
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/wireless/cfg80211.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/

# wifi driver
include machine/$(BOXTYPE)/linux-driver-wifi.mk
