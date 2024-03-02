#
# KERNEL
#
KERNEL_VER             = 4.1.20-1.9
KERNEL_DATE            = 20180206
KERNEL_SRC_VER         = 4.1.20
KERNEL_TYPE            = gbue4k
KERNEL_SRC             = gigablue-linux-$(KERNEL_SRC_VER)-$(KERNEL_DATE).tar.gz
KERNEL_URL             = https://source.mynonpublic.com/gigablue
KERNEL_CONFIG          = defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-$(KERNEL_SRC_VER)
KERNEL_IMAGE           = zImage
KERNEL_DTB_VER         = bcm7445-bcm97445svmb.dtb

#gigablue-linux-${PV}-20180206.tar.gz

KERNEL_PATCHES = \
		0002-linux_dvb-core.patch \
		0002-bcmgenet-recovery-fix.patch \
		0002-linux_4_1_1_9_dvbs2x.patch \
		0002-linux_dvb_adapter.patch \
		0002-linux_rpmb_not_alloc.patch \
		kernel-add-support-for-gcc6.patch \
		0001-regmap-add-regmap_write_bits.patch \
		0003-Add-support-for-dvb-usb-stick-Hauppauge-WinTV-soloHD.patch \
		0004-af9035-add-USB-ID-07ca-0337-AVerMedia-HD-Volar-A867.patch \
		0005-Add-support-for-EVOLVEO-XtraTV-stick.patch \
		0006-dib8000-Add-support-for-Mygica-Geniatech-S2870.patch \
		0007-dib0700-add-USB-ID-for-another-STK8096-PVR-ref-desig.patch \
		0008-add-Hama-Hybrid-DVB-T-Stick-support.patch \
		0009-Add-Terratec-H7-Revision-4-to-DVBSky-driver.patch \
		0010-media-Added-support-for-the-TerraTec-T1-DVB-T-USB-tu.patch \
		0011-media-tda18250-support-for-new-silicon-tuner.patch \
		0012-media-dib0700-add-support-for-Xbox-One-Digital-TV-Tu.patch \
		0013-mn88472-Fix-possible-leak-in-mn88472_init.patch \
		0014-staging-media-Remove-unneeded-parentheses.patch \
		0015-staging-media-mn88472-simplify-NULL-tests.patch \
		0016-mn88472-fix-typo.patch \
		0017-mn88472-finalize-driver.patch \
		0018-Add-support-for-dvb-usb-stick-Hauppauge-WinTV-dualHD.patch \
		0001-dvb-usb-fix-a867.patch \
		0001-Support-TBS-USB-drivers-for-4.1-kernel.patch \
		0001-TBS-fixes-for-4.1-kernel.patch \
		0001-STV-Add-PLS-support.patch \
		0001-STV-Add-SNR-Signal-report-parameters.patch \
		blindscan2.patch \
		0001-stv090x-optimized-TS-sync-control.patch \
		kernel-add-support-for-gcc7.patch \
		kernel-add-support-for-gcc8.patch \
		kernel-add-support-for-gcc9.patch \
		kernel-add-support-for-gcc10.patch \
		kernel-add-support-for-gcc11.patch \
		kernel-add-support-for-gcc12.patch \
		0002-log2-give-up-on-gcc-constant-optimizations.patch \
		0003-uaccess-dont-mark-register-as-const.patch \
		add-partition-specific-uevent-callbacks-for-partition-info.patch \
		move-default-dialect-to-SMB3.patch \
		fix-multiple-defs-yyloc.patch \

#
# DRIVER
#

DRIVER_VER   = $(KERNEL_VER)
LIBGLES_DATE = 20191101

DRIVER_DATE = 20200723
DRIVER_REV  = r1

UTIL_DATE   = $(DRIVER_DATE)
UTIL_REV    = r1

#
# IMAGE
#

MACHINE              = gb7252

# others
CAIRO_OPTS = \
		--enable-egl \
		--enable-glesv2

LINKS_PATCH_BOXTYPE = links-$(LINKS_VER)-event1-input.patch

GRAPHLCD_EXTRA_PATCH = graphlcd-gbue4k.patch

CUSTOM_RCS =

# release target
neutrino-release-gbue4k:
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/
	cp $(TARGET_DIR)/boot/zImage.dtb $(RELEASE_DIR)/boot/


