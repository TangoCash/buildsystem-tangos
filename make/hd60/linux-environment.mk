#
# KERNEL
#
KERNEL_VER             = 4.4.35
KERNEL_DATE            = 20200219
KERNEL_TYPE            = hd60
KERNEL_SRC             = linux-$(KERNEL_VER)-$(KERNEL_DATE)-arm.tar.gz
KERNEL_URL             = http://source.mynonpublic.com/gfutures
KERNEL_CONFIG          = $(KERNEL_TYPE)/defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-$(KERNEL_VER)
KERNEL_DTB_VER         = hi3798mv200.dtb

KERNEL_PATCHES = \
		armbox/$(KERNEL_TYPE)/0002-log2-give-up-on-gcc-constant-optimizations.patch \
		armbox/$(KERNEL_TYPE)/0003-dont-mark-register-as-const.patch \
		armbox/$(KERNEL_TYPE)/0001-remote.patch \
		armbox/$(KERNEL_TYPE)/HauppaugeWinTV-dualHD.patch \
		armbox/$(KERNEL_TYPE)/dib7000-linux_4.4.179.patch \
		armbox/$(KERNEL_TYPE)/dvb-usb-linux_4.4.179.patch \
		armbox/$(KERNEL_TYPE)/wifi-linux_4.4.183.patch \
		armbox/$(KERNEL_TYPE)/move-default-dialect-to-SMB3.patch \
		armbox/$(KERNEL_TYPE)/0004-linux-fix-buffer-size-warning-error.patch \
		armbox/$(KERNEL_TYPE)/modules_mark__inittest__exittest_as__maybe_unused.patch \
		armbox/$(KERNEL_TYPE)/includelinuxmodule_h_copy__init__exit_attrs_to_initcleanup_module.patch \
		armbox/$(KERNEL_TYPE)/Backport_minimal_compiler_attributes_h_to_support_GCC_9.patch \
		armbox/$(KERNEL_TYPE)/0005-xbox-one-tuner-4.4.patch \
		armbox/$(KERNEL_TYPE)/0006-dvb-media-tda18250-support-for-new-silicon-tuner.patch \
		armbox/$(KERNEL_TYPE)/0007-dvb-mn88472-staging.patch \
		armbox/$(KERNEL_TYPE)/mn88472_reset_stream_ID_reg_if_no_PLP_given.patch

# others
#CAIRO_OPTS = \
#		--enable-egl \
#		--enable-glesv2

LINKS_PATCH_BOXTYPE = links-$(LINKS_VER)-event1-input.patch

CUSTOM_RCS = $(SKEL_ROOT)/release/rcS_neutrino_$(BOXARCH)

# release target
neutrino-release-hd60:
	install -m 0755 $(SKEL_ROOT)/release/halt_hd60 $(RELEASE_DIR)/etc/init.d/halt
	install -m 0755 $(SKEL_ROOT)/bin/showiframe $(RELEASE_DIR)/bin
	cp -f $(SKEL_ROOT)/release/fstab_hd60 $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/uImage $(RELEASE_DIR)/boot/

