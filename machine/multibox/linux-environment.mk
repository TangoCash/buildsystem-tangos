#
# KERNEL
#
KERNEL_VER             = 4.4.35
KERNEL_DATE            = 20200219
KERNEL_TYPE            = multibox
KERNEL_SRC             = linux-$(KERNEL_VER)-$(KERNEL_DATE)-arm.tar.gz
KERNEL_URL             = http://source.mynonpublic.com/maxytec
KERNEL_CONFIG          = defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-$(KERNEL_VER)
KERNEL_IMAGE           = uImage
KERNEL_DTB_VER         = hi3798mv200.dtb

KERNEL_PATCHES = \
		0002-log2-give-up-on-gcc-constant-optimizations.patch \
		0003-dont-mark-register-as-const.patch \
		0001-remote.patch \
		HauppaugeWinTV-dualHD.patch \
		dib7000-linux_4.4.179.patch \
		dvb-usb-linux_4.4.179.patch \
		wifi-linux_4.4.183.patch \
		move-default-dialect-to-SMB3.patch \
		0004-linux-fix-buffer-size-warning-error.patch \
		modules_mark__inittest__exittest_as__maybe_unused.patch \
		includelinuxmodule_h_copy__init__exit_attrs_to_initcleanup_module.patch \
		Backport_minimal_compiler_attributes_h_to_support_GCC_9.patch \
		0005-xbox-one-tuner-4.4.patch \
		0006-dvb-media-tda18250-support-for-new-silicon-tuner.patch \
		0007-dvb-mn88472-staging.patch \
		mn88472_reset_stream_ID_reg_if_no_PLP_given.patch \
		4.4.35_fix-multiple-defs-yyloc.patch

#
# DRIVER
#

DRIVER_VER     = $(KERNEL_VER)
DRIVER_DATE    = 20201204
PLAYERLIB_DATE = 20200622
LIBGLES_DATE   = 20190104

#
# IMAGE
#

MACHINE              = maxytec
FLASH_BOOTARGS_DATE  = 20200504
FLASH_PARTITONS_DATE = 20200319
FLASH_RECOVERY_DATE  = 20210118

# others
#CAIRO_OPTS = \
#		--enable-egl \
#		--enable-glesv2

LINKS_PATCH_BOXTYPE = links-$(LINKS_VER)-event1-input.patch

CUSTOM_RCS = $(MACHINE_COMMON_DIR)/rcS_neutrino_$(BOXARCH)

# release target
neutrino-release-multiboxse:
	install -m 0755 $($(MACHINE_FILES))/showiframe $(RELEASE_DIR)/bin
	cp $(TARGET_DIR)/boot/uImage $(RELEASE_DIR)/boot/

