#
# KERNEL
#
KERNEL_VER             = 4.10.12
KERNEL_DATE            = 20180424
KERNEL_TYPE            = bre2ze4k
KERNEL_SRC             = linux-$(KERNEL_VER)-arm.tar.gz
KERNEL_URL             = http://source.mynonpublic.com/gfutures
KERNEL_CONFIG          = defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-$(KERNEL_VER)
KERNEL_IMAGE           = zImage
KERNEL_DTB_VER         = bcm7445-bcm97445svmb.dtb

KERNEL_PATCHES = \
		TBS-fixes-for-4.10-kernel.patch \
		0001-Support-TBS-USB-drivers-for-4.6-kernel.patch \
		0001-TBS-fixes-for-4.6-kernel.patch \
		0001-STV-Add-PLS-support.patch \
		0001-STV-Add-SNR-Signal-report-parameters.patch \
		blindscan2.patch \
		0001-stv090x-optimized-TS-sync-control.patch \
		reserve_dvb_adapter_0.patch \
		blacklist_mmc0.patch \
		export_pmpoweroffprepare.patch \
		t230c2.patch \
		add-more-devices-rtl8xxxu.patch \
		dvbs2x.patch \
		4.10.12_fix-multiple-defs-yyloc.patch

#
# DRIVER
#

DRIVER_VER   = $(KERNEL_VER)
DRIVER_DATE  = 20191120
LIBGLES_DATE = 20191101

# others
CAIRO_OPTS = \
		--enable-egl \
		--enable-glesv2

LINKS_PATCH_BOXTYPE = links-$(LINKS_VER)-event1-input.patch

CUSTOM_RCS     = $(MACHINE_COMMON_DIR)/rcS_neutrino_$(BOXARCH)
CUSTOM_INITTAB = $(SKEL_ROOT)/etc/inittab_ttyS0

# release target
neutrino-release-bre2ze4k:
ifeq ($(LAYOUT), multi)
	sed -i -e 's#/dev/mmcblk0p10#/dev/mmcblk0p7#g' $(RELEASE_DIR)/etc/fstab
	sed -i -e 's#/dev/mmcblk0p11#/dev/mmcblk0p9#g' $(RELEASE_DIR)/etc/fstab
endif
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/
	cp $(TARGET_DIR)/boot/zImage.dtb $(RELEASE_DIR)/boot/


