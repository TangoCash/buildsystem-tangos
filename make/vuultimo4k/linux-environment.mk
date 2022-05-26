### armbox vuultimo4k

KERNEL_VER             = 3.14.28-1.12
KERNEL_DATE            =
KERNEL_TYPE            = vuultimo4k
KERNEL_SRC_VER         = 3.14-1.12
KERNEL_SRC             = stblinux-${KERNEL_SRC_VER}.tar.bz2
KERNEL_URL             = http://code.vuplus.com/download/release/kernel
ifeq ($(VU_MULTIBOOT), 1)
KERNEL_CONFIG          = $(KERNEL_TYPE)/defconfig_multi
else
KERNEL_CONFIG          = $(KERNEL_TYPE)/defconfig
endif
KERNEL_DIR             = $(BUILD_TMP)/linux

KERNEL_INITRD          = vmlinuz-initrd-7445d0

KERNEL_PATCHES = \
		armbox/vuplus_common/3_14_bcm_genet_disable_warn.patch \
		armbox/vuplus_common/3_14_linux_dvb-core.patch \
		armbox/vuplus_common/3_14_dvbs2x.patch \
		armbox/vuplus_common/3_14_dmx_source_dvr.patch \
		armbox/vuplus_common/3_14_rt2800usb_fix_warn_tx_status_timeout_to_dbg.patch \
		armbox/vuplus_common/3_14_usb_core_hub_msleep.patch \
		armbox/vuplus_common/3_14_rtl8712_fix_build_error.patch \
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc6.patch \
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc7.patch \
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc8.patch \
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc9.patch \
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc10.patch \
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc11.patch \
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc12.patch \
		armbox/vuplus_common/3_14_0001-Support-TBS-USB-drivers.patch \
		armbox/vuplus_common/3_14_0001-STV-Add-PLS-support.patch \
		armbox/vuplus_common/3_14_0001-STV-Add-SNR-Signal-report-parameters.patch \
		armbox/vuplus_common/3_14_0001-stv090x-optimized-TS-sync-control.patch \
		armbox/vuplus_common/3_14_blindscan2.patch \
		armbox/vuplus_common/3_14_genksyms_fix_typeof_handling.patch \
		armbox/vuplus_common/3_14_0001-tuners-tda18273-silicon-tuner-driver.patch \
		armbox/vuplus_common/3_14_01-10-si2157-Silicon-Labs-Si2157-silicon-tuner-driver.patch \
		armbox/vuplus_common/3_14_02-10-si2168-Silicon-Labs-Si2168-DVB-T-T2-C-demod-driver.patch \
		armbox/vuplus_common/3_14_0003-cxusb-Geniatech-T230-support.patch \
		armbox/vuplus_common/3_14_CONFIG_DVB_SP2.patch \
		armbox/vuplus_common/3_14_dvbsky.patch \
		armbox/vuplus_common/3_14_rtl2832u-2.patch \
		armbox/vuplus_common/3_14_0004-log2-give-up-on-gcc-constant-optimizations.patch \
		armbox/vuplus_common/3_14_0005-uaccess-dont-mark-register-as-const.patch \
		armbox/vuplus_common/3_14_0006-makefile-disable-warnings.patch \
		armbox/vuplus_common/3_14_linux_dvb_adapter.patch \
		armbox/vuplus_common/3_14_fix-multiple-defs-yyloc.patch

KERNEL_PATCHES += \
		armbox/$(KERNEL_TYPE)/bcmsysport_3.14.28-1.12.patch \
		armbox/$(KERNEL_TYPE)/linux_prevent_usb_dma_from_bmem.patch

# others
CAIRO_OPTS =

LINKS_PATCH_BOXTYPE =

GRAPHLCD_EXTRA_PATCH = graphlcd-vuplus4k.patch

CUSTOM_RCS     = $(SKEL_ROOT)/release/rcS_neutrino_vu
CUSTOM_INITTAB = $(SKEL_ROOT)/etc/inittab_ttyS0

# release target
neutrino-release-vuultimo4k:
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
