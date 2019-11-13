#
# flashimage
#

flashimage:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd51))
	$(MAKE) flash-image-hd51-multi-disk flash-image-hd51-multi-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), h7))
	$(MAKE) flash-image-h7-multi-disk flash-image-h7-multi-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k))
	$(MAKE) flash-image-bre2ze4k-multi-disk flash-image-bre2ze4k-multi-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd60))
	$(MAKE) flash-image-hd60-multi-disk flash-image-hd60-multi-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd61))
	$(MAKE) flash-image-hd61-multi-disk flash-image-hd61-multi-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vusolo4k))
ifeq ($(VUSOLO4K_MULTIBOOT), 1)
	$(MAKE) flash-image-vusolo4k-multi-rootfs
else
	$(MAKE) flash-image-vusolo4k-rootfs
endif
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k))
ifeq ($(VUDUO4K_MULTIBOOT), 1)
	$(MAKE) flash-image-vuduo4k-multi-rootfs
else
	$(MAKE) flash-image-vuduo4k-rootfs
endif
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo))
	$(MAKE) flash-image-vuduo
endif
	$(TUXBOX_CUSTOMIZE)

ofgimage:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd51))
	$(MAKE) ITYPE=ofg flash-image-hd51-multi-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), h7))
	$(MAKE) ITYPE=ofg flash-image-h7-multi-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k))
	$(MAKE) ITYPE=ofg flash-image-bre2ze4k-multi-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd60))
	$(MAKE) ITYPE=ofg flash-image-hd60-multi-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd61))
	$(MAKE) ITYPE=ofg flash-image-hd61-multi-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vusolo4k))
	$(MAKE) ITYPE=ofg flash-image-vusolo4k-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k))
	$(MAKE) ITYPE=ofg flash-image-vuduo4k-rootfs
endif
	$(TUXBOX_CUSTOMIZE)

oi \
online-image:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd51))
	$(MAKE) ITYPE=online flash-image-hd51-online
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), h7))
	$(MAKE) ITYPE=online flash-image-h7-online
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k))
	$(MAKE) ITYPE=online flash-image-bre2ze4k-online
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd60))
	$(MAKE) ITYPE=online flash-image-hd60-online
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd61))
	$(MAKE) ITYPE=online flash-image-hd61-online
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vusolo4k))
	$(MAKE) ITYPE=online flash-image-vusolo4k-online
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k))
	$(MAKE) ITYPE=online flash-image-vuduo4k-online
endif
	$(TUXBOX_CUSTOMIZE)

flash-clean:
	echo ""

### armbox vusolo4k
# general
VUSOLO4K_BUILD_TMP = $(BUILD_TMP)/image-build
VUSOLO4K_PREFIX = vuplus/solo4k

flash-image-vusolo4k-multi-rootfs:
	rm -rf $(VUSOLO4K_BUILD_TMP) || true
	mkdir -p $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)
	cp $(RELEASE_DIR)/boot/vmlinuz-initrd-7366c0 $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/initrd_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/kernel1_auto.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/rootfs.tar --exclude=zImage* --exclude=vmlinuz-initrd* . > /dev/null 2>&1; \
	bzip2 $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/rootfs.tar
	mv $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/rootfs.tar.bz2 $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/rootfs1.tar.bz2
	echo This file forces a reboot after the update. > $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/reboot.update
	echo This file forces creating partitions. > $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/mkpart.update
	echo Dummy for update. > $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/kernel_auto.bin
	echo Dummy for update. > $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/rootfs.tar.bz2
	echo $(BOXTYPE)_DDT_multi_usb_$(shell date '+%d%m%Y-%H%M%S') > $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/imageversion
	cd $(VUSOLO4K_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_multi_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').zip $(VUSOLO4K_PREFIX)/rootfs*.tar.bz2 $(VUSOLO4K_PREFIX)/initrd_auto.bin $(VUSOLO4K_PREFIX)/kernel*_auto.bin $(VUSOLO4K_PREFIX)/*.update $(VUSOLO4K_PREFIX)/imageversion
	# cleanup
	rm -rf $(VUSOLO4K_BUILD_TMP)

flash-image-vusolo4k-rootfs:
	rm -rf $(VUSOLO4K_BUILD_TMP) || true
	mkdir -p $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)
	cp $(RELEASE_DIR)/boot/vmlinuz-initrd-7366c0 $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/initrd_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/kernel_auto.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/rootfs.tar --exclude=zImage* --exclude=vmlinuz-initrd* . > /dev/null 2>&1; \
	bzip2 $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/rootfs.tar
	echo This file forces a reboot after the update. > $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/reboot.update
	echo This file forces creating partitions. > $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/mkpart.update
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(VUSOLO4K_BUILD_TMP)/$(VUSOLO4K_PREFIX)/imageversion
	cd $(VUSOLO4K_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').zip $(VUSOLO4K_PREFIX)/rootfs.tar.bz2 $(VUSOLO4K_PREFIX)/initrd_auto.bin $(VUSOLO4K_PREFIX)/kernel_auto.bin $(VUSOLO4K_PREFIX)/*.update $(VUSOLO4K_PREFIX)/imageversion
	# cleanup
	rm -rf $(VUSOLO4K_BUILD_TMP)

flash-image-vusolo4k-online:
	rm -rf $(VUSOLO4K_BUILD_TMP) || true
	mkdir -p $(VUSOLO4K_BUILD_TMP)/$(BOXTYPE)
	cp $(RELEASE_DIR)/boot/vmlinuz-initrd-7366c0 $(VUSOLO4K_BUILD_TMP)/$(BOXTYPE)/initrd_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(VUSOLO4K_BUILD_TMP)/$(BOXTYPE)/kernel_auto.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(VUSOLO4K_BUILD_TMP)/$(BOXTYPE)/rootfs.tar --exclude=zImage* --exclude=vmlinuz-initrd* . > /dev/null 2>&1; \
	bzip2 $(VUSOLO4K_BUILD_TMP)/$(BOXTYPE)/rootfs.tar
	echo This file forces a reboot after the update. > $(VUSOLO4K_BUILD_TMP)/$(BOXTYPE)/reboot.update
	echo This file forces creating partitions. > $(VUSOLO4K_BUILD_TMP)/$(BOXTYPE)/mkpart.update
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(VUSOLO4K_BUILD_TMP)/$(BOXTYPE)/imageversion
	cd $(VUSOLO4K_BUILD_TMP)/$(BOXTYPE) && \
	tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_multi_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').tgz rootfs.tar.bz2 initrd_auto.bin kernel_auto.bin *.update imageversion
	# cleanup
	rm -rf $(VUSOLO4K_BUILD_TMP)

### armbox vuduo4k
# general
VUDUO4K_BUILD_TMP = $(BUILD_TMP)/image-build
VUDUO4K_PREFIX = vuplus/duo4k

flash-image-vuduo4k-multi-rootfs:
	rm -rf $(VUDUO4K_BUILD_TMP) || true
	mkdir -p $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)
	cp $(RELEASE_DIR)/boot/vmlinuz-initrd-7278b1 $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/initrd_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/kernel1_auto.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/rootfs.tar --exclude=zImage* --exclude=vmlinuz-initrd* . > /dev/null 2>&1; \
	bzip2 $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/rootfs.tar
	mv $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/rootfs.tar.bz2 $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/rootfs1.tar.bz2
	echo This file forces a reboot after the update. > $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/reboot.update
	echo This file forces creating partitions. > $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/mkpart.update
	echo Dummy for update. > $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/kernel_auto.bin
	echo Dummy for update. > $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/rootfs.tar.bz2
	echo $(BOXTYPE)_DDT_multi_usb_$(shell date '+%d%m%Y-%H%M%S') > $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/imageversion
	cd $(VUDUO4K_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_multi_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').zip $(VUDUO4K_PREFIX)/rootfs*.tar.bz2 $(VUDUO4K_PREFIX)/initrd_auto.bin $(VUDUO4K_PREFIX)/kernel*_auto.bin $(VUDUO4K_PREFIX)/*.update $(VUDUO4K_PREFIX)/imageversion
	# cleanup
	rm -rf $(VUDUO4K_BUILD_TMP)

flash-image-vuduo4k-rootfs:
	rm -rf $(VUDUO4K_BUILD_TMP) || true
	mkdir -p $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)
	cp $(RELEASE_DIR)/boot/vmlinuz-initrd-7278b1 $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/initrd_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/kernel_auto.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/rootfs.tar --exclude=zImage* --exclude=vmlinuz-initrd* . > /dev/null 2>&1; \
	bzip2 $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/rootfs.tar
	echo This file forces a reboot after the update. > $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/reboot.update
	echo This file forces creating partitions. > $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/mkpart.update
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(VUDUO4K_BUILD_TMP)/$(VUDUO4K_PREFIX)/imageversion
	cd $(VUDUO4K_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').zip $(VUDUO4K_PREFIX)/rootfs.tar.bz2 $(VUDUO4K_PREFIX)/initrd_auto.bin $(VUDUO4K_PREFIX)/kernel_auto.bin $(VUDUO4K_PREFIX)/*.update $(VUDUO4K_PREFIX)/imageversion
	# cleanup
	rm -rf $(VUDUO4K_BUILD_TMP)

flash-image-vuduo4k-online:
	rm -rf $(VUDUO4K_BUILD_TMP) || true
	mkdir -p $(VUDUO4K_BUILD_TMP)/$(BOXTYPE)
	cp $(RELEASE_DIR)/boot/vmlinuz-initrd-7278b1 $(VUDUO4K_BUILD_TMP)/$(BOXTYPE)/initrd_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(VUDUO4K_BUILD_TMP)/$(BOXTYPE)/kernel_auto.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(VUDUO4K_BUILD_TMP)/$(BOXTYPE)/rootfs.tar --exclude=zImage* --exclude=vmlinuz-initrd* . > /dev/null 2>&1; \
	bzip2 $(VUDUO4K_BUILD_TMP)/$(BOXTYPE)/rootfs.tar
	echo This file forces a reboot after the update. > $(VUDUO4K_BUILD_TMP)/$(BOXTYPE)/reboot.update
	echo This file forces creating partitions. > $(VUDUO4K_BUILD_TMP)/$(BOXTYPE)/mkpart.update
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(VUDUO4K_BUILD_TMP)/$(BOXTYPE)/imageversion
	cd $(VUDUO4K_BUILD_TMP)/$(BOXTYPE) && \
	tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_multi_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').tgz rootfs.tar.bz2 initrd_auto.bin kernel_auto.bin *.update imageversion
	# cleanup
	rm -rf $(VUDUO4K_BUILD_TMP)

### mipsbox vuduo
# general
VUDUO_PREFIX = vuplus/duo
VUDUO_BUILD_TMP = $(BUILD_TMP)/image-build

flash-image-vuduo:
	rm -rf $(VUDUO_BUILD_TMP) || true
	mkdir -p $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)
	touch $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)/reboot.update
	cp $(RELEASE_DIR)/boot/kernel_cfe_auto.bin $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)
	mkfs.ubifs -r $(RELEASE_DIR) -o $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)/root_cfe_auto.ubi -m 2048 -e 126976 -c 4096 -F
	echo '[ubifs]' > $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'mode=ubi' >> $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'image=$(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)/root_cfe_auto.ubi' >> $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_id=0' >> $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_type=dynamic' >> $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_name=rootfs' >> $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_flags=autoresize' >> $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)/ubinize.cfg
	ubinize -o $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)/root_cfe_auto.jffs2 -m 2048 -p 128KiB $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)/ubinize.cfg
	rm -f $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)/root_cfe_auto.ubi
	rm -f $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)/ubinize.cfg
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(VUDUO_BUILD_TMP)/$(VUDUO_PREFIX)/imageversion
	cd $(VUDUO_BUILD_TMP)/ && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_usb_$(shell date '+%d.%m.%Y-%H.%M').zip $(VUDUO_PREFIX)*
	# cleanup
	rm -rf $(VUDUO_BUILD_TMP)
