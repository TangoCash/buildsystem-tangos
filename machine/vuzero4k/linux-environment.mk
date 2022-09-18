### armbox vuzero4k

KERNEL_VER             = 4.1.20-1.9
KERNEL_DATE            =
KERNEL_TYPE            = vuzero4k
KERNEL_SRC_VER         = 4.1-1.9
KERNEL_SRC             = stblinux-${KERNEL_SRC_VER}.tar.bz2
KERNEL_URL             = http://code.vuplus.com/download/release/kernel
ifeq ($(VU_MULTIBOOT), 1)
KERNEL_CONFIG          = defconfig_multi
else
KERNEL_CONFIG          = defconfig
endif
KERNEL_DIR             = $(BUILD_TMP)/linux
KERNEL_IMAGE           = zImage
KERNEL_DTB_VER         =
KERNEL_INITRD          = vmlinuz-initrd-7260a0
KERNEL_CPDIR           = ../../common/patches/vuplus

KERNEL_PATCHES = \
		$(KERNEL_CPDIR)/4_1_linux_dvb_adapter.patch \
		$(KERNEL_CPDIR)/4_1_linux_dvb-core.patch \
		$(KERNEL_CPDIR)/4_1_linux_4_1_45_dvbs2x.patch \
		$(KERNEL_CPDIR)/4_1_dmx_source_dvr.patch \
		$(KERNEL_CPDIR)/4_1_bcmsysport_4_1_45.patch \
		$(KERNEL_CPDIR)/4_1_linux_usb_hub.patch \
		$(KERNEL_CPDIR)/4_1_0001-regmap-add-regmap_write_bits.patch \
		$(KERNEL_CPDIR)/4_1_0002-af9035-fix-device-order-in-ID-list.patch \
		$(KERNEL_CPDIR)/4_1_0003-Add-support-for-dvb-usb-stick-Hauppauge-WinTV-soloHD.patch \
		$(KERNEL_CPDIR)/4_1_0004-af9035-add-USB-ID-07ca-0337-AVerMedia-HD-Volar-A867.patch \
		$(KERNEL_CPDIR)/4_1_0005-Add-support-for-EVOLVEO-XtraTV-stick.patch \
		$(KERNEL_CPDIR)/4_1_0006-dib8000-Add-support-for-Mygica-Geniatech-S2870.patch \
		$(KERNEL_CPDIR)/4_1_0007-dib0700-add-USB-ID-for-another-STK8096-PVR-ref-desig.patch \
		$(KERNEL_CPDIR)/4_1_0008-add-Hama-Hybrid-DVB-T-Stick-support.patch \
		$(KERNEL_CPDIR)/4_1_0009-Add-Terratec-H7-Revision-4-to-DVBSky-driver.patch \
		$(KERNEL_CPDIR)/4_1_0010-media-Added-support-for-the-TerraTec-T1-DVB-T-USB-tu.patch \
		$(KERNEL_CPDIR)/4_1_0011-media-tda18250-support-for-new-silicon-tuner.patch \
		$(KERNEL_CPDIR)/4_1_0012-media-dib0700-add-support-for-Xbox-One-Digital-TV-Tu.patch \
		$(KERNEL_CPDIR)/4_1_0013-mn88472-Fix-possible-leak-in-mn88472_init.patch \
		$(KERNEL_CPDIR)/4_1_0014-staging-media-Remove-unneeded-parentheses.patch \
		$(KERNEL_CPDIR)/4_1_0015-staging-media-mn88472-simplify-NULL-tests.patch \
		$(KERNEL_CPDIR)/4_1_0016-mn88472-fix-typo.patch \
		$(KERNEL_CPDIR)/4_1_0017-mn88472-finalize-driver.patch \
		$(KERNEL_CPDIR)/4_1_0001-dvb-usb-fix-a867.patch \
		$(KERNEL_CPDIR)/4_1_kernel-add-support-for-gcc6.patch \
		$(KERNEL_CPDIR)/4_1_kernel-add-support-for-gcc7.patch \
		$(KERNEL_CPDIR)/4_1_kernel-add-support-for-gcc8.patch \
		$(KERNEL_CPDIR)/4_1_kernel-add-support-for-gcc9.patch \
		$(KERNEL_CPDIR)/4_1_kernel-add-support-for-gcc10.patch \
		$(KERNEL_CPDIR)/4_1_kernel-add-support-for-gcc11.patch \
		$(KERNEL_CPDIR)/4_1_kernel-add-support-for-gcc12.patch \
		$(KERNEL_CPDIR)/4_1_0001-Support-TBS-USB-drivers-for-4.1-kernel.patch \
		$(KERNEL_CPDIR)/4_1_0001-TBS-fixes-for-4.1-kernel.patch \
		$(KERNEL_CPDIR)/4_1_0001-STV-Add-PLS-support.patch \
		$(KERNEL_CPDIR)/4_1_0001-STV-Add-SNR-Signal-report-parameters.patch \
		$(KERNEL_CPDIR)/4_1_blindscan2.patch \
		$(KERNEL_CPDIR)/4_1_0001-stv090x-optimized-TS-sync-control.patch \
		$(KERNEL_CPDIR)/4_1_0002-log2-give-up-on-gcc-constant-optimizations.patch \
		$(KERNEL_CPDIR)/4_1_0003-uaccess-dont-mark-register-as-const.patch \
		$(KERNEL_CPDIR)/4_1_fix-multiple-defs-yyloc.patch

KERNEL_PATCHES += \
		bcmgenet-recovery-fix.patch \
		linux_rpmb_not_alloc.patch

#
# DRIVER
#

DRIVER_VER  = 4.1.20
DRIVER_DATE = 20190424
DRIVER_REV  = r0

UTIL_VER    = 17.1
UTIL_DATE   = $(DRIVER_DATE)
UTIL_REV    = r0

GLES_VER    = 17.1
GLES_DATE   = $(DRIVER_DATE)
GLES_REV    = r0

INITRD_DATE = 20170522

#
# IMAGE
#

VU_PREFIX       = vuplus/zero4k
VU_INITRD       = $(KERNEL_INITRD)
VU_FR           = echo This file forces the update. > $(FLASH_BUILD_TMP)/$(VU_PREFIX)/force.update

# others
CAIRO_OPTS =

LINKS_PATCH_BOXTYPE =

CUSTOM_RCS     = $(MACHINE_COMMON_DIR)/rcS_neutrino_vu
CUSTOM_INITTAB = $(SKEL_ROOT)/etc/inittab_ttyS0

# release target
neutrino-release-vuzero4k:
	rm -f $(RELEASE_DIR)/lib/modules/fpga_directc.ko
ifeq ($(VU_MULTIBOOT), 1)
	cp $(MACHINE_FILES)/$(KERNEL_INITRD) $(RELEASE_DIR)/boot/
else
	cp $(TARGET_DIR)/boot/$(KERNEL_INITRD) $(RELEASE_DIR)/boot/
endif
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/
