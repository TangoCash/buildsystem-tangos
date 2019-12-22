### armbox vuzero4k

KERNEL_VER             = 4.1.20-1.9
KERNEL_DATE            =
KERNEL_TYPE            = vuzero4k
KERNEL_SRC_VER         = 4.1-1.9
KERNEL_SRC             = stblinux-${KERNEL_SRC_VER}.tar.bz2
KERNEL_URL             = http://archive.vuplus.com/download/kernel
ifeq ($(VU_MULTIBOOT), 1)
KERNEL_CONFIG          = $(KERNEL_TYPE)/defconfig_multi
else
KERNEL_CONFIG          = $(KERNEL_TYPE)/defconfig
endif
KERNEL_DIR             = $(BUILD_TMP)/linux

KERNEL_INITRD          = vmlinuz-initrd-7260a0

KERNEL_PATCHES = \
		armbox/vuplus_common/4_1_linux_dvb_adapter.patch \
		armbox/vuplus_common/4_1_linux_dvb-core.patch \
		armbox/vuplus_common/4_1_linux_4_1_45_dvbs2x.patch \
		armbox/vuplus_common/4_1_dmx_source_dvr.patch \
		armbox/vuplus_common/4_1_bcmsysport_4_1_45.patch \
		armbox/vuplus_common/4_1_linux_usb_hub.patch \
		armbox/vuplus_common/4_1_0001-regmap-add-regmap_write_bits.patch \
		armbox/vuplus_common/4_1_0002-af9035-fix-device-order-in-ID-list.patch \
		armbox/vuplus_common/4_1_0003-Add-support-for-dvb-usb-stick-Hauppauge-WinTV-soloHD.patch \
		armbox/vuplus_common/4_1_0004-af9035-add-USB-ID-07ca-0337-AVerMedia-HD-Volar-A867.patch \
		armbox/vuplus_common/4_1_0005-Add-support-for-EVOLVEO-XtraTV-stick.patch \
		armbox/vuplus_common/4_1_0006-dib8000-Add-support-for-Mygica-Geniatech-S2870.patch \
		armbox/vuplus_common/4_1_0007-dib0700-add-USB-ID-for-another-STK8096-PVR-ref-desig.patch \
		armbox/vuplus_common/4_1_0008-add-Hama-Hybrid-DVB-T-Stick-support.patch \
		armbox/vuplus_common/4_1_0009-Add-Terratec-H7-Revision-4-to-DVBSky-driver.patch \
		armbox/vuplus_common/4_1_0010-media-Added-support-for-the-TerraTec-T1-DVB-T-USB-tu.patch \
		armbox/vuplus_common/4_1_0011-media-tda18250-support-for-new-silicon-tuner.patch \
		armbox/vuplus_common/4_1_0012-media-dib0700-add-support-for-Xbox-One-Digital-TV-Tu.patch \
		armbox/vuplus_common/4_1_0013-mn88472-Fix-possible-leak-in-mn88472_init.patch \
		armbox/vuplus_common/4_1_0014-staging-media-Remove-unneeded-parentheses.patch \
		armbox/vuplus_common/4_1_0015-staging-media-mn88472-simplify-NULL-tests.patch \
		armbox/vuplus_common/4_1_0016-mn88472-fix-typo.patch \
		armbox/vuplus_common/4_1_0017-mn88472-finalize-driver.patch \
		armbox/vuplus_common/4_1_0001-dvb-usb-fix-a867.patch \
		armbox/vuplus_common/4_1_kernel-add-support-for-gcc6.patch \
		armbox/vuplus_common/4_1_kernel-add-support-for-gcc7.patch \
		armbox/vuplus_common/4_1_kernel-add-support-for-gcc8.patch \
		armbox/vuplus_common/4_1_0001-Support-TBS-USB-drivers-for-4.1-kernel.patch \
		armbox/vuplus_common/4_1_0001-TBS-fixes-for-4.1-kernel.patch \
		armbox/vuplus_common/4_1_0001-STV-Add-PLS-support.patch \
		armbox/vuplus_common/4_1_0001-STV-Add-SNR-Signal-report-parameters.patch \
		armbox/vuplus_common/4_1_blindscan2.patch \
		armbox/vuplus_common/4_1_0001-stv090x-optimized-TS-sync-control.patch \
		armbox/vuplus_common/4_1_0002-log2-give-up-on-gcc-constant-optimizations.patch \
		armbox/vuplus_common/4_1_0003-uaccess-dont-mark-register-as-const.patch

KERNEL_PATCHES += \
		armbox/vuuno4kse_bcmgenet-recovery-fix.patch \
		armbox/vuuno4kse_linux_rpmb_not_alloc.patch

# crosstool
CUSTOM_KERNEL_VER = $(KERNEL_SRC_VER)
CROSSTOOL_BOXTYPE_PATCH = $(PATCHES)/ct-ng/crosstool-ng-$(CROSSTOOL_NG_VER)-vu-kernel.patch

# others
CAIRO_OPTS =

LINKS_PATCH_BOXTYPE =

CUSTOM_RCS     =
CUSTOM_INITTAB =

# release target
neutrino-release-vuzero4k:
	install -m 0755 $(SKEL_ROOT)/release/halt_$(KERNEL_TYPE) $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_$(KERNEL_TYPE) $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	rm -f $(RELEASE_DIR)/lib/modules/fpga_directc.ko
ifeq ($(VU_MULTIBOOT), 1)
	cp $(SKEL_ROOT)/release/$(KERNEL_INITRD) $(RELEASE_DIR)/boot/
else
	cp $(TARGET_DIR)/boot/$(KERNEL_INITRD) $(RELEASE_DIR)/boot/
endif
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/
