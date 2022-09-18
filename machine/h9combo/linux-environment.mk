#
# KERNEL
#
KERNEL_VER             = 4.4.35
KERNEL_DATE            = 20200508
KERNEL_TYPE            = h9combo
KERNEL_SRC             = linux-$(KERNEL_VER)-$(KERNEL_DATE)-arm.tar.gz
KERNEL_URL             = http://source.mynonpublic.com/zgemma
KERNEL_CONFIG          = defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-$(KERNEL_VER)
KERNEL_IMAGE           = uImage
KERNEL_DTB_VER         = hi3798mv200.dtb

KERNEL_PATCHES = \
		0001-mmc-switch-1.8V.patch \
		0001-remote.patch \
		HauppaugeWinTV-dualHD.patch \
		dib7000-linux_4.4.179.patch \
		dvb-usb-linux_4.4.179.patch \
		0002-log2-give-up-on-gcc-constant-optimizations.patch \
		0003-dont-mark-register-as-const.patch \
		wifi-linux_4.4.183.patch \
		0004-linux-fix-buffer-size-warning-error.patch \
		modules_mark__inittest__exittest_as__maybe_unused.patch \
		includelinuxmodule_h_copy__init__exit_attrs_to_initcleanup_module.patch \
		Backport_minimal_compiler_attributes_h_to_support_GCC_9.patch \
		0005-xbox-one-tuner-4.4.patch \
		0006-dvb-media-tda18250-support-for-new-silicon-tuner.patch \
		0007-dvb-mn88472-staging.patch \
		mn88472_reset_stream_ID_reg_if_no_PLP_given.patch \
		af9035.patch \
		4.4.35_fix-multiple-defs-yyloc.patch

#
# DRIVER
#

#DRIVER_VER     = $(KERNEL_VER)
#DRIVER_DATE    = 20200731
#PLAYERLIB_DATE = 20200622
#LIBGLES_DATE   = 20181201

#
# IMAGE
#

#MACHINE              = octagon
#FLASH_BOOTARGS_DATE  = 20200504
#FLASH_PARTITONS_DATE = 20200319
#FLASH_RECOVERY_DATE  = 20200424

# others
#CAIRO_OPTS = \
#		--enable-egl \
#		--enable-glesv2

LINKS_PATCH_BOXTYPE = links-$(LINKS_VER)-event2-input.patch

CUSTOM_RCS     =
CUSTOM_INITTAB = $(SKEL_ROOT)/etc/inittab_ttyS0

# release target
neutrino-release-h9combo:
	install -m 0755 $(MACHINE_FILES)/rcS_neutrino $(RELEASE_DIR)/etc/init.d/rcS
	install -m 0755 $(MACHINE_FILES)/halt $(RELEASE_DIR)/etc/init.d/halt
	install -m 0644	$(MACHINE_FILES)/fstab $(RELEASE_DIR)/etc/fstab
	install -m 0755 $(SKEL_ROOT)/etc/init.d/mmcblk-by-name $(RELEASE_DIR)/etc/init.d/mmcblk-by-name
ifeq ($(LAYOUT), multi)
	sed -i -e 's#/dev/mmcblk0p10#/dev/mmcblk0p7#g' $(RELEASE_DIR)/etc/fstab
	sed -i -e 's#/dev/mmcblk0p11#/dev/mmcblk0p9#g' $(RELEASE_DIR)/etc/fstab
endif
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/uImage $(RELEASE_DIR)/boot/

