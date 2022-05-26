#
# KERNEL
#
KERNEL_VER             = 4.8.17
KERNEL_TYPE            = osninoplus
KERNEL_SRC_VER         = edision-4.8.17
KERNEL_SRC             = linux-edision-$(KERNEL_VER).tar.xz
KERNEL_URL             = http://source.mynonpublic.com/edision
KERNEL_CONFIG          = $(KERNEL_TYPE)/defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-$(KERNEL_VER)

KERNEL_PATCHES = \
		mipsbox/$(KERNEL_TYPE)/0001-Support-TBS-USB-drivers-for-4.6-kernel.patch \
		mipsbox/$(KERNEL_TYPE)/0001-TBS-fixes-for-4.6-kernel.patch \
		mipsbox/$(KERNEL_TYPE)/0001-STV-Add-PLS-support.patch \
		mipsbox/$(KERNEL_TYPE)/0001-STV-Add-SNR-Signal-report-parameters.patch \
		mipsbox/$(KERNEL_TYPE)/blindscan2.patch \
		mipsbox/$(KERNEL_TYPE)/0001-stv090x-optimized-TS-sync-control.patch \
		mipsbox/$(KERNEL_TYPE)/0002-log2-give-up-on-gcc-constant-optimizations.patch \
		mipsbox/$(KERNEL_TYPE)/0003-cp1emu-do-not-use-bools-for-arithmetic.patch \
		mipsbox/$(KERNEL_TYPE)/makefile-silence-warnings.patch

# others
CUSTOM_RCS     =
CUSTOM_INITTAB =

# release target
neutrino-release-osninoplus:
	install -m 0755 $(SKEL_ROOT)/release/halt_osninoplus $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_osninoplus $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/

