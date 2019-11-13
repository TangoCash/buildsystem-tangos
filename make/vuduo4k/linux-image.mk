#
# flashimage
#
### armbox vuduo4k
# general
FLASH_BUILD_TMP = $(BUILD_TMP)/image-build
FLASH_PREFIX = vuplus/duo4k

flash-image-vuduo4k-multi-rootfs:
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)
	cp $(RELEASE_DIR)/boot/vmlinuz-initrd-7278b1 $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/initrd_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/kernel1_auto.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/rootfs.tar --exclude=zImage* --exclude=vmlinuz-initrd* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/rootfs.tar
	mv $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/rootfs.tar.bz2 $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/rootfs1.tar.bz2
	echo This file forces a reboot after the update. > $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/reboot.update
	echo This file forces creating partitions. > $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/mkpart.update
	echo Dummy for update. > $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/kernel_auto.bin
	echo Dummy for update. > $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/rootfs.tar.bz2
	echo $(BOXTYPE)_DDT_multi_usb_$(shell date '+%d%m%Y-%H%M%S') > $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/imageversion
	cd $(FLASH_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_multi_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').zip $(FLASH_PREFIX)/rootfs*.tar.bz2 $(FLASH_PREFIX)/initrd_auto.bin $(FLASH_PREFIX)/kernel*_auto.bin $(FLASH_PREFIX)/*.update $(FLASH_PREFIX)/imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)

flash-image-vuduo4k-rootfs:
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)
	cp $(RELEASE_DIR)/boot/vmlinuz-initrd-7278b1 $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/initrd_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/kernel_auto.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/rootfs.tar --exclude=zImage* --exclude=vmlinuz-initrd* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/rootfs.tar
	echo This file forces a reboot after the update. > $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/reboot.update
	echo This file forces creating partitions. > $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/mkpart.update
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/imageversion
	cd $(FLASH_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').zip $(FLASH_PREFIX)/rootfs.tar.bz2 $(FLASH_PREFIX)/initrd_auto.bin $(FLASH_PREFIX)/kernel_auto.bin $(FLASH_PREFIX)/*.update $(FLASH_PREFIX)/imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)

flash-image-vuduo4k-online:
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(BOXTYPE)
	cp $(RELEASE_DIR)/boot/vmlinuz-initrd-7278b1 $(FLASH_BUILD_TMP)/$(BOXTYPE)/initrd_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(FLASH_BUILD_TMP)/$(BOXTYPE)/kernel_auto.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar --exclude=zImage* --exclude=vmlinuz-initrd* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar
	echo This file forces a reboot after the update. > $(FLASH_BUILD_TMP)/$(BOXTYPE)/reboot.update
	echo This file forces creating partitions. > $(FLASH_BUILD_TMP)/$(BOXTYPE)/mkpart.update
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(FLASH_BUILD_TMP)/$(BOXTYPE)/imageversion
	cd $(FLASH_BUILD_TMP)/$(BOXTYPE) && \
	tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_multi_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').tgz rootfs.tar.bz2 initrd_auto.bin kernel_auto.bin *.update imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)
