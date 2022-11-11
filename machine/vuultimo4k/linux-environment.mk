### armbox vuultimo4k

KERNEL_VER             = 3.14.28-1.12
KERNEL_DATE            =
KERNEL_TYPE            = vuultimo4k
KERNEL_SRC_VER         = 3.14-1.12
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
KERNEL_INITRD          = vmlinuz-initrd-7445d0
KERNEL_CPDIR           = ../../common/patches/vuplus

KERNEL_PATCHES = \
		$(KERNEL_CPDIR)/3_14_bcm_genet_disable_warn.patch \
		$(KERNEL_CPDIR)/3_14_linux_dvb-core.patch \
		$(KERNEL_CPDIR)/3_14_dvbs2x.patch \
		$(KERNEL_CPDIR)/3_14_dmx_source_dvr.patch \
		$(KERNEL_CPDIR)/3_14_rt2800usb_fix_warn_tx_status_timeout_to_dbg.patch \
		$(KERNEL_CPDIR)/3_14_usb_core_hub_msleep.patch \
		$(KERNEL_CPDIR)/3_14_rtl8712_fix_build_error.patch \
		$(KERNEL_CPDIR)/3_14_kernel-add-support-for-gcc6.patch \
		$(KERNEL_CPDIR)/3_14_kernel-add-support-for-gcc7.patch \
		$(KERNEL_CPDIR)/3_14_kernel-add-support-for-gcc8.patch \
		$(KERNEL_CPDIR)/3_14_kernel-add-support-for-gcc9.patch \
		$(KERNEL_CPDIR)/3_14_kernel-add-support-for-gcc10.patch \
		$(KERNEL_CPDIR)/3_14_kernel-add-support-for-gcc11.patch \
		$(KERNEL_CPDIR)/3_14_kernel-add-support-for-gcc12.patch \
		$(KERNEL_CPDIR)/3_14_0001-Support-TBS-USB-drivers.patch \
		$(KERNEL_CPDIR)/3_14_0001-STV-Add-PLS-support.patch \
		$(KERNEL_CPDIR)/3_14_0001-STV-Add-SNR-Signal-report-parameters.patch \
		$(KERNEL_CPDIR)/3_14_0001-stv090x-optimized-TS-sync-control.patch \
		$(KERNEL_CPDIR)/3_14_blindscan2.patch \
		$(KERNEL_CPDIR)/3_14_genksyms_fix_typeof_handling.patch \
		$(KERNEL_CPDIR)/3_14_0001-tuners-tda18273-silicon-tuner-driver.patch \
		$(KERNEL_CPDIR)/3_14_01-10-si2157-Silicon-Labs-Si2157-silicon-tuner-driver.patch \
		$(KERNEL_CPDIR)/3_14_02-10-si2168-Silicon-Labs-Si2168-DVB-T-T2-C-demod-driver.patch \
		$(KERNEL_CPDIR)/3_14_0003-cxusb-Geniatech-T230-support.patch \
		$(KERNEL_CPDIR)/3_14_CONFIG_DVB_SP2.patch \
		$(KERNEL_CPDIR)/3_14_dvbsky.patch \
		$(KERNEL_CPDIR)/3_14_rtl2832u-2.patch \
		$(KERNEL_CPDIR)/3_14_0004-log2-give-up-on-gcc-constant-optimizations.patch \
		$(KERNEL_CPDIR)/3_14_0005-uaccess-dont-mark-register-as-const.patch \
		$(KERNEL_CPDIR)/3_14_0006-makefile-disable-warnings.patch \
		$(KERNEL_CPDIR)/3_14_linux_dvb_adapter.patch \
		$(KERNEL_CPDIR)/3_14_fix-multiple-defs-yyloc.patch

KERNEL_PATCHES += \
		bcmsysport_3.14.28-1.12.patch \
		linux_prevent_usb_dma_from_bmem.patch

#
# DRIVER
#

DRIVER_VER  = 3.14.28
DRIVER_DATE = 20190424
DRIVER_REV  = r0

UTIL_VER    = 17.1
UTIL_DATE   = $(DRIVER_DATE)
UTIL_REV    = r0

GLES_VER    = 17.1
GLES_DATE   = $(DRIVER_DATE)
GLES_REV    = r0

INITRD_DATE = 20170209

#
# IMAGE
#

VU_PREFIX       = vuplus/ultimo4k
VU_INITRD       = $(KERNEL_INITRD)
VU_FR           = echo This file forces a reboot after the update. > $(FLASH_BUILD_TMP)/$(VU_PREFIX)/reboot.update

# others
CAIRO_OPTS =

LINKS_PATCH_BOXTYPE =

GRAPHLCD_EXTRA_PATCH = graphlcd-vuplus4k.patch
LCD4LINUX_EXTRA_DRIVER = VUPLUS4K

CUSTOM_RCS     = $(MACHINE_COMMON_DIR)/rcS_neutrino_vu
CUSTOM_INITTAB = $(SKEL_ROOT)/etc/inittab_ttyS0

# release target
neutrino-release-vuultimo4k:
	rm -f $(RELEASE_DIR)/lib/modules/fpga_directc.ko
ifeq ($(VU_MULTIBOOT), 1)
	cp $(MACHINE_FILES)/$(KERNEL_INITRD) $(RELEASE_DIR)/boot/
else
	cp $(TARGET_DIR)/boot/$(KERNEL_INITRD) $(RELEASE_DIR)/boot/
endif
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/
