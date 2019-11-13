#
# KERNEL
#
ifeq ($(BOXTYPE), vusolo4k)
KERNEL_VER             = 3.14.28-1.8
KERNEL_TYPE            = vusolo4k
KERNEL_SRC_VER         = 3.14-1.8
KERNEL_SRC             = stblinux-${KERNEL_SRC_VER}.tar.bz2
KERNEL_URL             = http://archive.vuplus.com/download/kernel
ifeq ($(VUSOLO4K_MULTIBOOT), 1)
KERNEL_CONFIG          = vusolo4k_defconfig_multi
else
KERNEL_CONFIG          = vusolo4k_defconfig
endif
KERNEL_DIR             = $(BUILD_TMP)/linux
KERNEL_PATCHES_ARM     = $(VUSOLO4K_PATCHES)
endif

ifeq ($(BOXTYPE), vuduo4k)
KERNEL_VER             = 4.1.45-1.17
KERNEL_TYPE            = vuduo4k
KERNEL_SRC_VER         = 4.1-1.17
KERNEL_SRC             = stblinux-${KERNEL_SRC_VER}.tar.bz2
KERNEL_URL             = http://archive.vuplus.com/download/kernel
ifeq ($(VUDUO4K_MULTIBOOT), 1)
KERNEL_CONFIG          = vuduo4k_defconfig_multi
else
KERNEL_CONFIG          = vuduo4k_defconfig
endif
KERNEL_DIR             = $(BUILD_TMP)/linux
KERNEL_PATCHES_ARM     = $(VUDUO4K_PATCHES)
endif

#
# Todo: findkerneldevice.py

DEPMOD = $(HOST_DIR)/bin/depmod

#
# Patches Kernel
#
COMMON_PATCHES_ARM = \

VUSOLO4K_PATCHES = \
		armbox/vusolo4k_bcm_genet_disable_warn.patch \
		armbox/vusolo4k_linux_dvb-core.patch \
		armbox/vusolo4k_rt2800usb_fix_warn_tx_status_timeout_to_dbg.patch \
		armbox/vusolo4k_usb_core_hub_msleep.patch \
		armbox/vusolo4k_rtl8712_fix_build_error.patch \
		armbox/vusolo4k_0001-Support-TBS-USB-drivers.patch \
		armbox/vusolo4k_0001-STV-Add-PLS-support.patch \
		armbox/vusolo4k_0001-STV-Add-SNR-Signal-report-parameters.patch \
		armbox/vusolo4k_0001-stv090x-optimized-TS-sync-control.patch \
		armbox/vusolo4k_linux_dvb_adapter.patch \
		armbox/vusolo4k_kernel-gcc6.patch \
		armbox/vusolo4k_genksyms_fix_typeof_handling.patch \
		armbox/vusolo4k_0001-tuners-tda18273-silicon-tuner-driver.patch \
		armbox/vusolo4k_01-10-si2157-Silicon-Labs-Si2157-silicon-tuner-driver.patch \
		armbox/vusolo4k_02-10-si2168-Silicon-Labs-Si2168-DVB-T-T2-C-demod-driver.patch \
		armbox/vusolo4k_0003-cxusb-Geniatech-T230-support.patch \
		armbox/vusolo4k_CONFIG_DVB_SP2.patch \
		armbox/vusolo4k_dvbsky.patch \
		armbox/vusolo4k_rtl2832u-2.patch

VUDUO4K_PATCHES = \
		armbox/vuduo4k_bcmsysport_4_1_45.patch \
		armbox/vuduo4k_linux_dvb-core.patch \
		armbox/vuduo4k_linux_dvb_adapter.patch \
		armbox/vuduo4k_linux_usb_hub.patch

#
# KERNEL
#
KERNEL_PATCHES = $(KERNEL_PATCHES_ARM)

$(ARCHIVE)/$(KERNEL_SRC):
	$(DOWNLOAD) $(KERNEL_URL)/$(KERNEL_SRC)

$(D)/kernel.do_prepare: $(ARCHIVE)/$(KERNEL_SRC) $(PATCHES)/armbox/$(KERNEL_CONFIG)
	$(START_BUILD)
	rm -rf $(KERNEL_DIR)
	$(UNTAR)/$(KERNEL_SRC)
	set -e; cd $(KERNEL_DIR); \
		for i in $(KERNEL_PATCHES); do \
			echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$i"; \
			$(PATCH)/$$i; \
		done
	install -m 644 $(PATCHES)/armbox/$(KERNEL_CONFIG) $(KERNEL_DIR)/.config
ifeq ($(NEWLAYOUT), $(filter $(NEWLAYOUT), 1))
	sed -i -e 's#CONFIG_INITRAMFS_SOURCE=""#CONFIG_INITRAMFS_SOURCE="initramfs-subdirboot.cpio.gz"\nCONFIG_INITRAMFS_ROOT_UID=0\nCONFIG_INITRAMFS_ROOT_GID=0#g' $(KERNEL_DIR)/.config
	cp $(PATCHES)/initramfs-subdirboot.cpio.gz $(KERNEL_DIR)
endif
ifeq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), kerneldebug debug))
	@echo "Using kernel debug"
	@grep -v "CONFIG_PRINTK" "$(KERNEL_DIR)/.config" > $(KERNEL_DIR)/.config.tmp
	cp $(KERNEL_DIR)/.config.tmp $(KERNEL_DIR)/.config
	@echo "CONFIG_PRINTK=y" >> $(KERNEL_DIR)/.config
	@echo "CONFIG_PRINTK_TIME=y" >> $(KERNEL_DIR)/.config
endif
	@touch $@

$(D)/kernel.do_compile: $(D)/kernel.do_prepare
ifeq ($(BOXTYPE), vusolo4k)
	set -e; cd $(KERNEL_DIR); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm oldconfig
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- zImage modules
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	@touch $@
endif
ifeq ($(BOXTYPE), vuduo4k)
	set -e; cd $(KERNEL_DIR); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm oldconfig
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- zImage modules
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	@touch $@
endif

KERNEL = $(D)/kernel
$(D)/kernel: $(D)/bootstrap $(D)/kernel.do_compile
ifeq ($(BOXTYPE), vusolo4k)
	install -m 644 $(KERNEL_DIR)/vmlinux $(TARGET_DIR)/boot/vmlinux-arm-$(KERNEL_VER)
	install -m 644 $(KERNEL_DIR)/System.map $(TARGET_DIR)/boot/System.map-arm-$(KERNEL_VER)
	cp $(KERNEL_DIR)/arch/arm/boot/zImage $(TARGET_DIR)/boot/
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/build || true
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/source || true
	$(TOUCH)
endif
ifeq ($(BOXTYPE), vuduo4k)
	install -m 644 $(KERNEL_DIR)/vmlinux $(TARGET_DIR)/boot/vmlinux-arm-$(KERNEL_VER)
	install -m 644 $(KERNEL_DIR)/System.map $(TARGET_DIR)/boot/System.map-arm-$(KERNEL_VER)
	cp $(KERNEL_DIR)/arch/arm/boot/zImage $(TARGET_DIR)/boot/
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/build || true
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/source || true
	$(TOUCH)
endif

kernel-distclean:
	rm -f $(D)/kernel
	rm -f $(D)/kernel.do_compile
	rm -f $(D)/kernel.do_prepare

kernel-clean:
	-$(MAKE) -C $(KERNEL_DIR) clean
	rm -f $(D)/kernel
	rm -f $(D)/kernel.do_compile

#
# Helper
#
kernel.menuconfig kernel.xconfig: \
kernel.%: $(D)/kernel
	$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- $*
	@echo ""
	@echo "You have to edit $(PATCHES)/armbox/$(KERNEL_CONFIG) m a n u a l l y to make changes permanent !!!"
	@echo ""
	diff $(KERNEL_DIR)/.config.old $(KERNEL_DIR)/.config
	@echo ""
