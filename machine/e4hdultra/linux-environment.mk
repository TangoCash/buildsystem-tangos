#
# KERNEL
#
KERNEL_VER             = 4.10.12
KERNEL_DATE            = 20180424
KERNEL_TYPE            = e4hdultra
KERNEL_SRC             = ceryon-linux-$(KERNEL_VER)-arm.tar.gz
KERNEL_URL             = http://source.mynonpublic.com/ceryon
KERNEL_CONFIG          = defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-$(KERNEL_VER)
KERNEL_IMAGE           = zImage
KERNEL_DTB_VER         = 

KERNEL_PATCHES = \
		TBS-fixes-for-4.10-kernel.patch \
		0001-Support-TBS-USB-drivers-for-4.6-kernel.patch \
		0001-TBS-fixes-for-4.6-kernel.patch \
		0001-STV-Add-PLS-support.patch \
		0001-STV-Add-SNR-Signal-report-parameters.patch \
		blindscan2.patch \
		dvbs2x.patch \
		0001-stv090x-optimized-TS-sync-control.patch \
		reserve_dvb_adapter_0.patch \
		blacklist_mmc0.patch \
		export_pmpoweroffprepare.patch \
		4.10.12_fix-multiple-defs-yyloc.patch \
		v3-1-3-media-si2157-Add-support-for-Si2141-A10.patch \
		v3-2-3-media-si2168-add-support-for-Si2168-D60.patch \
		v3-3-3-media-dvbsky-MyGica-T230C-support.patch \
		v3-3-4-media-dvbsky-MyGica-T230C-support.patch \
		v3-3-5-media-dvbsky-MyGica-T230C-support.patch \
		0002-cp1emu-do-not-use-bools-for-arithmetic.patch \
		move-default-dialect-to-SMB3.patch \
		add-more-devices-rtl8xxxu.patch \
		0005-xbox-one-tuner-4.10.patch \
		0006-dvb-media-tda18250-support-for-new-silicon-tuner.patch

#
# DRIVER
#

DRIVER_DATE = 20191101
DRIVER_VER = 4.10.12-$(DRIVER_DATE)
DRIVER_SRC = e4hd-drivers-$(DRIVER_VER).zip
DRIVER_URL = http://source.mynonpublic.com/ceryon

LIBGLES_DATE = 20191101
LIBGLES_SRC  = 8100s-v3ddriver-$(LIBGLES_DATE).zip
LIBGLES_URL  = https://source.mynonpublic.com/ceryon

LIBGLES_HEADERS = hd-v3ddriver-headers.tar.gz

# others
CAIRO_OPTS = \
		--enable-egl \
		--enable-glesv2

LINKS_PATCH_BOXTYPE = links-$(LINKS_VER)-event1-input.patch

GRAPHLCD_EXTRA_PATCH = graphlcd-e4hdultra.patch

CUSTOM_RCS     =
CUSTOM_INITTAB = $(SKEL_ROOT)/etc/inittab_ttyS0

# release target
neutrino-release-e4hdultra:
ifeq ($(LAYOUT), multi)
	sed -i -e 's#/dev/mmcblk0p10#/dev/mmcblk0p7#g' $(RELEASE_DIR)/etc/fstab
	sed -i -e 's#/dev/mmcblk0p11#/dev/mmcblk0p9#g' $(RELEASE_DIR)/etc/fstab
endif
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/


