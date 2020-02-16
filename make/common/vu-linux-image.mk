
flash-image-vu-multi-rootfs:
	# Create final USB-image
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(VU_PREFIX)
	cp $(RELEASE_DIR)/boot/$(VU_INITRD) $(FLASH_BUILD_TMP)/$(VU_PREFIX)/initrd_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(FLASH_BUILD_TMP)/$(VU_PREFIX)/kernel1_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(FLASH_BUILD_TMP)/$(VU_PREFIX)/kernel2_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(FLASH_BUILD_TMP)/$(VU_PREFIX)/kernel3_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(FLASH_BUILD_TMP)/$(VU_PREFIX)/kernel4_auto.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(VU_PREFIX)/rootfs.tar --exclude=zImage* --exclude=vmlinuz-initrd* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(VU_PREFIX)/rootfs.tar
	mv $(FLASH_BUILD_TMP)/$(VU_PREFIX)/rootfs.tar.bz2 $(FLASH_BUILD_TMP)/$(VU_PREFIX)/rootfs1.tar.bz2
	cp $(FLASH_BUILD_TMP)/$(VU_PREFIX)/rootfs1.tar.bz2 $(FLASH_BUILD_TMP)/$(VU_PREFIX)/rootfs2.tar.bz2
	cp $(FLASH_BUILD_TMP)/$(VU_PREFIX)/rootfs1.tar.bz2 $(FLASH_BUILD_TMP)/$(VU_PREFIX)/rootfs3.tar.bz2
	cp $(FLASH_BUILD_TMP)/$(VU_PREFIX)/rootfs1.tar.bz2 $(FLASH_BUILD_TMP)/$(VU_PREFIX)/rootfs4.tar.bz2
	$(VU_FR)
	echo This file forces creating partitions. > $(FLASH_BUILD_TMP)/$(VU_PREFIX)/mkpart.update
	echo Dummy for update. > $(FLASH_BUILD_TMP)/$(VU_PREFIX)/kernel_auto.bin
	echo Dummy for update. > $(FLASH_BUILD_TMP)/$(VU_PREFIX)/rootfs.tar.bz2
	echo $(BOXTYPE)_DDT_multi_usb_$(shell date '+%d%m%Y-%H%M%S') > $(FLASH_BUILD_TMP)/$(VU_PREFIX)/imageversion
	cd $(FLASH_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_multi_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').zip $(VU_PREFIX)/rootfs*.tar.bz2 $(VU_PREFIX)/initrd_auto.bin $(VU_PREFIX)/kernel*_auto.bin $(VU_PREFIX)/*.update $(VU_PREFIX)/imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)

flash-image-vu-rootfs:
	# Create final USB-image
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(VU_PREFIX)
	cp $(RELEASE_DIR)/boot/$(VU_INITRD) $(FLASH_BUILD_TMP)/$(VU_PREFIX)/initrd_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(FLASH_BUILD_TMP)/$(VU_PREFIX)/kernel_auto.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(VU_PREFIX)/rootfs.tar --exclude=zImage* --exclude=vmlinuz-initrd* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(VU_PREFIX)/rootfs.tar
	$(VU_FR)
	echo This file forces creating partitions. > $(FLASH_BUILD_TMP)/$(VU_PREFIX)/mkpart.update
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(FLASH_BUILD_TMP)/$(VU_PREFIX)/imageversion
	cd $(FLASH_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').zip $(VU_PREFIX)/rootfs.tar.bz2 $(VU_PREFIX)/initrd_auto.bin $(VU_PREFIX)/kernel_auto.bin $(VU_PREFIX)/*.update $(VU_PREFIX)/imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)

flash-image-vu-online:
	# Create final USB-image
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(VU_PREFIX)
	cp $(RELEASE_DIR)/boot/$(VU_INITRD) $(FLASH_BUILD_TMP)/$(VU_PREFIX)/initrd_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(FLASH_BUILD_TMP)/$(VU_PREFIX)/kernel_auto.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(VU_PREFIX)/rootfs.tar --exclude=zImage* --exclude=vmlinuz-initrd* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(VU_PREFIX)/rootfs.tar
	$(VU_FR)
	echo This file forces creating partitions. > $(FLASH_BUILD_TMP)/$(VU_PREFIX)/mkpart.update
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(FLASH_BUILD_TMP)/$(VU_PREFIX)/imageversion
	cd $(FLASH_BUILD_TMP)/$(VU_PREFIX) && \
	tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').tgz rootfs.tar.bz2 initrd_auto.bin kernel_auto.bin *.update imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)
