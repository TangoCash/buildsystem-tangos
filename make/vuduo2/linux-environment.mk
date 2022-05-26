#
# KERNEL
#
KERNEL_VER             = 3.13.5
KERNEL_TYPE            = vuduo2
KERNEL_SRC_VER         = 3.13.5
KERNEL_SRC             = stblinux-${KERNEL_SRC_VER}.tar.bz2
KERNEL_URL             = http://code.vuplus.com/download/release/kernel
KERNEL_CONFIG          = $(KERNEL_TYPE)/defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux

KERNEL_PATCHES = \
		mipsbox/$(KERNEL_TYPE)/kernel-add-support-for-gcc5.patch \
		mipsbox/$(KERNEL_TYPE)/kernel-add-support-for-gcc6.patch \
		mipsbox/$(KERNEL_TYPE)/kernel-add-support-for-gcc7.patch \
		mipsbox/$(KERNEL_TYPE)/kernel-add-support-for-gcc8.patch \
		mipsbox/$(KERNEL_TYPE)/kernel-add-support-for-gcc9.patch \
		mipsbox/$(KERNEL_TYPE)/kernel-add-support-for-gcc10.patch \
		mipsbox/$(KERNEL_TYPE)/rt2800usb_fix_warn_tx_status_timeout_to_dbg.patch \
		mipsbox/$(KERNEL_TYPE)/add-dmx-source-timecode.patch \
		mipsbox/$(KERNEL_TYPE)/af9015-output-full-range-SNR.patch \
		mipsbox/$(KERNEL_TYPE)/af9033-output-full-range-SNR.patch \
		mipsbox/$(KERNEL_TYPE)/as102-adjust-signal-strength-report.patch \
		mipsbox/$(KERNEL_TYPE)/as102-scale-MER-to-full-range.patch \
		mipsbox/$(KERNEL_TYPE)/cxd2820r-output-full-range-SNR.patch \
		mipsbox/$(KERNEL_TYPE)/dvb-usb-dib0700-disable-sleep.patch \
		mipsbox/$(KERNEL_TYPE)/dvb_usb_disable_rc_polling.patch \
		mipsbox/$(KERNEL_TYPE)/it913x-switch-off-PID-filter-by-default.patch \
		mipsbox/$(KERNEL_TYPE)/tda18271-advertise-supported-delsys.patch \
		mipsbox/$(KERNEL_TYPE)/mxl5007t-add-no_probe-and-no_reset-parameters.patch \
		mipsbox/$(KERNEL_TYPE)/linux-tcp_output.patch \
		mipsbox/$(KERNEL_TYPE)/linux-3.13-gcc-4.9.3-build-error-fixed.patch \
		mipsbox/$(KERNEL_TYPE)/rtl8712-fix-warnings.patch \
		mipsbox/$(KERNEL_TYPE)/0001-Support-TBS-USB-drivers-3.13.patch \
		mipsbox/$(KERNEL_TYPE)/0001-STV-Add-PLS-support.patch \
		mipsbox/$(KERNEL_TYPE)/0001-STV-Add-SNR-Signal-report-parameters.patch \
		mipsbox/$(KERNEL_TYPE)/0001-stv090x-optimized-TS-sync-control.patch \
		mipsbox/$(KERNEL_TYPE)/0002-cp1emu-do-not-use-bools-for-arithmetic.patch \
		mipsbox/$(KERNEL_TYPE)/0003-log2-give-up-on-gcc-constant-optimizations.patch \
		mipsbox/$(KERNEL_TYPE)/blindscan2.patch \
		mipsbox/$(KERNEL_TYPE)/linux_dvb_adapter.patch \
		mipsbox/$(KERNEL_TYPE)/genksyms_fix_typeof_handling.patch \
		mipsbox/$(KERNEL_TYPE)/test.patch \
		mipsbox/$(KERNEL_TYPE)/0001-tuners-tda18273-silicon-tuner-driver.patch \
		mipsbox/$(KERNEL_TYPE)/T220-kern-13.patch \
		mipsbox/$(KERNEL_TYPE)/01-10-si2157-Silicon-Labs-Si2157-silicon-tuner-driver.patch \
		mipsbox/$(KERNEL_TYPE)/02-10-si2168-Silicon-Labs-Si2168-DVB-T-T2-C-demod-driver.patch \
		mipsbox/$(KERNEL_TYPE)/CONFIG_DVB_SP2.patch \
		mipsbox/$(KERNEL_TYPE)/dvbsky.patch \
		mipsbox/$(KERNEL_TYPE)/fix_hfsplus.patch \
		mipsbox/$(KERNEL_TYPE)/mac80211_hwsim-fix-compiler-warning-on-MIPS.patch \
		mipsbox/$(KERNEL_TYPE)/prism2fw.patch \
		mipsbox/$(KERNEL_TYPE)/mm-Move-__vma_address-to-internal.h-to-be-inlined-in-huge_memory.c.patch \
		mipsbox/$(KERNEL_TYPE)/compile-with-gcc9.patch

# others
CUSTOM_RCS     =
CUSTOM_INITTAB =

# release target
neutrino-release-vuduo2:
	install -m 0755 $(SKEL_ROOT)/release/halt_vuduo2 $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_vuduo2 $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/kernel_cfe_auto.bin $(RELEASE_DIR)/boot/
	cp $(TARGET_DIR)/boot/initrd_cfe_auto.bin $(RELEASE_DIR)/boot/

