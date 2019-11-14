#
# KERNEL
#
KERNEL_VER             = 4.10.12
KERNEL_DATE            = 20180424
KERNEL_TYPE            = hd51
KERNEL_SRC             = linux-$(KERNEL_VER)-arm.tar.gz
KERNEL_URL             = http://source.mynonpublic.com/gfutures
KERNEL_CONFIG          = $(KERNEL_TYPE)/defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-$(KERNEL_VER)
KERNEL_DTB_VER         = bcm7445-bcm97445svmb.dtb

KERNEL_PATCHES = \
		armbox/$(KERNEL_TYPE)/TBS-fixes-for-4.10-kernel.patch \
		armbox/$(KERNEL_TYPE)/0001-Support-TBS-USB-drivers-for-4.6-kernel.patch \
		armbox/$(KERNEL_TYPE)/0001-TBS-fixes-for-4.6-kernel.patch \
		armbox/$(KERNEL_TYPE)/0001-STV-Add-PLS-support.patch \
		armbox/$(KERNEL_TYPE)/0001-STV-Add-SNR-Signal-report-parameters.patch \
		armbox/$(KERNEL_TYPE)/blindscan2.patch \
		armbox/$(KERNEL_TYPE)/0001-stv090x-optimized-TS-sync-control.patch \
		armbox/$(KERNEL_TYPE)/reserve_dvb_adapter_0.patch \
		armbox/$(KERNEL_TYPE)/blacklist_mmc0.patch \
		armbox/$(KERNEL_TYPE)/export_pmpoweroffprepare.patch \
		armbox/$(KERNEL_TYPE)/t230c2.patch \
		armbox/$(KERNEL_TYPE)/add-more-devices-rtl8xxxu.patch

# crosstool
CUSTOM_KERNEL_VER       = $(KERNEL_VER)-arm
CROSSTOOL_BOXTYPE_PATCH =

# others
CAIRO_OPTS = \
		--enable-egl \
		--enable-glesv2

LINKS_PATCH_BOXTYPE = links-$(LINKS_VER)-event1-input.patch

CUSTOM_RCS     = $(SKEL_ROOT)/release/rcS_neutrino_$(BOXARCH)
CUSTOM_INITTAB = $(SKEL_ROOT)/etc/inittab_ttyS0

# release target
neutrino-release-hd51:
	install -m 0755 $(SKEL_ROOT)/release/halt_hd51 $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_hd51 $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/
	cp $(TARGET_DIR)/boot/zImage.dtb $(RELEASE_DIR)/boot/
	install -m 0644 $(SKEL_ROOT)/release/tangos_hd51.m2v $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/bootlogo.m2v

