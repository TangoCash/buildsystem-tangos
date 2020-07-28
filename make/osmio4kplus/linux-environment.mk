#
# KERNEL
#
KERNEL_VER             = 5.5.16
KERNEL_SOURCE_VER      = 5.5.16
KERNEL_TYPE            = osmio4kplus
KERNEL_SRC             = linux-edision-$(KERNEL_SOURCE_VER).tar.gz
KERNEL_URL             = http://source.mynonpublic.com/edision
KERNEL_CONFIG          = $(KERNEL_TYPE)/defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-brcmstb-$(KERNEL_SOURCE_VER)

KERNEL_PATCHES =

# crosstool
CUSTOM_KERNEL_VER       = edision-$(KERNEL_SOURCE_VER)
CROSSTOOL_BOXTYPE_PATCH =

# others
CAIRO_OPTS =

LINKS_PATCH_BOXTYPE = links-$(LINKS_VER)-event1-input.patch

CUSTOM_RCS     =
CUSTOM_INITTAB =

# release target
neutrino-release-osmio4kplus:
	install -m 0755 $(SKEL_ROOT)/release/halt_osmio4kplus $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_osmio4kplus $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/Image.gz $(RELEASE_DIR)/boot/
	install -m 0644 $(SKEL_ROOT)/release/tangos_hd51.m2v $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/bootlogo.m2v

