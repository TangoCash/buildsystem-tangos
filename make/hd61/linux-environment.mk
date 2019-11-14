#
# KERNEL
#
KERNEL_VER             = 4.4.35
KERNEL_DATE            = 20181228
KERNEL_TYPE            = hd61
KERNEL_SRC             = linux-$(KERNEL_VER)-$(KERNEL_DATE)-arm.tar.gz
KERNEL_URL             = http://downloads.mutant-digital.net
KERNEL_CONFIG          = $(KERNEL_TYPE)/defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-$(KERNEL_VER)
KERNEL_DTB_VER         = hi3798mv200.dtb

KERNEL_PATCHES = \
		armbox/$(KERNEL_TYPE)/ieee80211-increase-scan-result-expire-time.patch \
		armbox/$(KERNEL_TYPE)/0001-remote.patch \
		armbox/$(KERNEL_TYPE)/0002-log2-give-up-on-gcc-constant-optimizations.patch \
		armbox/$(KERNEL_TYPE)/0003-dont-mark-register-as-const.patch

# crosstool
CUSTOM_KERNEL_VER       = $(KERNEL_VER)-$(KERNEL_DATE)-arm
CROSSTOOL_BOXTYPE_PATCH =

# others
CAIRO_OPTS = \
		--enable-egl \
		--enable-glesv2

LINKS_PATCH_BOXTYPE = links-$(LINKS_VER)-event1-input.patch

CUSTOM_RCS = $(SKEL_ROOT)/release/rcS_neutrino_$(BOXARCH)

# release target
neutrino-release-hd61:
	install -m 0755 $(SKEL_ROOT)/release/halt_hd61 $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_hd60 $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/uImage $(RELEASE_DIR)/boot/
	install -m 0644 $(SKEL_ROOT)/release/tangos_hd51.m2v $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/bootlogo.m2v

