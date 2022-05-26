#
# KERNEL
#
KERNEL_VER             = 3.9.6
KERNEL_TYPE            = vuduo
KERNEL_SRC_VER         = 3.9.6
KERNEL_SRC             = stblinux-${KERNEL_SRC_VER}.tar.bz2
KERNEL_URL             = http://code.vuplus.com/download/release/kernel
KERNEL_CONFIG          = $(KERNEL_TYPE)/defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux

KERNEL_PATCHES = \
		mipsbox/$(KERNEL_TYPE)/add-dmx-source-timecode.patch \
		mipsbox/$(KERNEL_TYPE)/af9015-output-full-range-SNR.patch \
		mipsbox/$(KERNEL_TYPE)/af9033-output-full-range-SNR.patch \
		mipsbox/$(KERNEL_TYPE)/as102-adjust-signal-strength-report.patch \
		mipsbox/$(KERNEL_TYPE)/as102-scale-MER-to-full-range.patch \
		mipsbox/$(KERNEL_TYPE)/cinergy_s2_usb_r2.patch \
		mipsbox/$(KERNEL_TYPE)/cxd2820r-output-full-range-SNR.patch \
		mipsbox/$(KERNEL_TYPE)/dvb-usb-dib0700-disable-sleep.patch \
		mipsbox/$(KERNEL_TYPE)/dvb_usb_disable_rc_polling.patch \
		mipsbox/$(KERNEL_TYPE)/it913x-switch-off-PID-filter-by-default.patch \
		mipsbox/$(KERNEL_TYPE)/tda18271-advertise-supported-delsys.patch \
		mipsbox/$(KERNEL_TYPE)/fix-dvb-siano-sms-order.patch \
		mipsbox/$(KERNEL_TYPE)/mxl5007t-add-no_probe-and-no_reset-parameters.patch \
		mipsbox/$(KERNEL_TYPE)/nfs-max-rwsize-8k.patch \
		mipsbox/$(KERNEL_TYPE)/0001-rt2800usb-add-support-for-rt55xx.patch \
		mipsbox/$(KERNEL_TYPE)/linux-sata_bcm.patch \
		mipsbox/$(KERNEL_TYPE)/fix_fuse_for_linux_mips_3-9.patch \
		mipsbox/$(KERNEL_TYPE)/rt2800usb_fix_warn_tx_status_timeout_to_dbg.patch \
		mipsbox/$(KERNEL_TYPE)/linux-3.9-gcc-4.9.3-build-error-fixed.patch \
		mipsbox/$(KERNEL_TYPE)/kernel-add-support-for-gcc-5.patch \
		mipsbox/$(KERNEL_TYPE)/rtl8712-fix-warnings.patch \
		mipsbox/$(KERNEL_TYPE)/rtl8187se-fix-warnings.patch \
		mipsbox/$(KERNEL_TYPE)/kernel-add-support-for-gcc6.patch \
		mipsbox/$(KERNEL_TYPE)/0001-Support-TBS-USB-drivers-3.9.patch \
		mipsbox/$(KERNEL_TYPE)/0001-STV-Add-PLS-support.patch \
		mipsbox/$(KERNEL_TYPE)/0001-STV-Add-SNR-Signal-report-parameters.patch \
		mipsbox/$(KERNEL_TYPE)/0001-stv090x-optimized-TS-sync-control.patch \
		mipsbox/$(KERNEL_TYPE)/blindscan2.patch \
		mipsbox/$(KERNEL_TYPE)/genksyms_fix_typeof_handling.patch \
		mipsbox/$(KERNEL_TYPE)/kernel-add-support-for-gcc7.patch \
		mipsbox/$(KERNEL_TYPE)/test.patch \
		mipsbox/$(KERNEL_TYPE)/01-10-si2157-Silicon-Labs-Si2157-silicon-tuner-driver.patch \
		mipsbox/$(KERNEL_TYPE)/02-10-si2168-Silicon-Labs-Si2168-DVB-T-T2-C-demod-driver.patch \
		mipsbox/$(KERNEL_TYPE)/CONFIG_DVB_SP2.patch \
		mipsbox/$(KERNEL_TYPE)/dvbsky-t330.patch
#		mipsbox/$(KERNEL_TYPE)/fixed_mtd.patch

# others
CUSTOM_RCS     =
CUSTOM_INITTAB =

# release target
neutrino-release-vuduo:
	install -m 0755 $(SKEL_ROOT)/release/halt_vuduo $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_vuduo $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/kernel_cfe_auto.bin $(RELEASE_DIR)/boot/

