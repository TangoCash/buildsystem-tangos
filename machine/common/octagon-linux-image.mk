#
# flashimage
#
# general
FLASH_IMAGE_NAME = disk

FLASH_PARTITONS_SRC = $(BOXTYPE)-partitions-$(FLASH_PARTITONS_DATE).zip
BUILDIMAGE_SRC = buildimage.zip

ROOTFS_SIZE = 320k #2*128k + 64k

$(ARCHIVE)/$(FLASH_PARTITONS_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/$(MACHINE)/$(FLASH_PARTITONS_SRC)

$(ARCHIVE)/$(BUILDIMAGE_SRC):
	$(DOWNLOAD) https://github.com/oe-alliance/oe-alliance-core/raw/5.0/meta-brands/meta-$(MACHINE)/recipes-bsp/$(MACHINE)-buildimage/$(BUILDIMAGE_SRC)

flash-image-$(BOXTYPE)-multi-disk: $(ARCHIVE)/$(BUILDIMAGE_SRC) $(ARCHIVE)/$(FLASH_PARTITONS_SRC)
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(BOXTYPE)
	cp $(RELEASE_DIR)/tmp/uImage $(FLASH_BUILD_TMP)/$(BOXTYPE)/uImage
	unzip -o $(ARCHIVE)/$(FLASH_PARTITONS_SRC) -d $(FLASH_BUILD_TMP)
	install -m 0755 $(FLASH_BUILD_TMP)/patitions/apploader.bin $(RELEASE_DIR)/usr/share/apploader.bin
	install -m 0755 $(FLASH_BUILD_TMP)/patitions/bootargs.bin $(RELEASE_DIR)/usr/share/bootargs.bin
	install -m 0755 $(FLASH_BUILD_TMP)/patitions/fastboot.bin $(RELEASE_DIR)/usr/share/fastboot.bin
	install -m 0755 $(FLASH_BUILD_TMP)/patitions/apploader.bin $(FLASH_BUILD_TMP)/apploader.bin
	install -m 0755 $(FLASH_BUILD_TMP)/patitions/bootargs.bin $(FLASH_BUILD_TMP)/bootargs.bin
	install -m 0755 $(FLASH_BUILD_TMP)/patitions/fastboot.bin $(FLASH_BUILD_TMP)/fastboot.bin
	$(REMOVE)/userdata
	install -d $(FLASH_BUILD_TMP)/userdata
	install -d $(FLASH_BUILD_TMP)/userdata/linuxrootfs1
	install -d $(FLASH_BUILD_TMP)/userdata/linuxrootfs2
	install -d $(FLASH_BUILD_TMP)/userdata/linuxrootfs3
	install -d $(FLASH_BUILD_TMP)/userdata/linuxrootfs4
	cp -a $(RELEASE_DIR) $(FLASH_BUILD_TMP)/userdata
	
	if [ -e $(RELEASE_DIR)/tmp/logo.img ]; then \
		cp -rf $(RELEASE_DIR)/tmp/logo.img $(FLASH_BUILD_TMP)/$(BOXTYPE); \
	fi
	$(MAKE) buildimage-tool
	echo $(ROOTFS_SIZE)
	echo $(COUNT)
	dd if=/dev/zero of=$(FLASH_BUILD_TMP)/$(FLASH_IMAGE_NAME).rootfs.ext4 seek=$(ROOTFS_SIZE) count=0 bs=1024
	mkfs.ext4 -F -i 4096 $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_NAME).rootfs.ext4 -d $(FLASH_BUILD_TMP)/userdata
	fsck.ext4 -pvfD $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_NAME).rootfs.ext4 || [ $? -le 3 ]
	cp $(FLASH_BUILD_TMP)/$(BOXTYPE)/uImage $(FLASH_BUILD_TMP)/patitions/kernel.bin
	cp $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_NAME).rootfs.ext4 $(FLASH_BUILD_TMP)/patitions/rootfs.ext4
	$(FLASH_BUILD_TMP)/mkupdate -s 00000003-00000001-01010101 -f $(FLASH_BUILD_TMP)/patitions/emmc_partitions.xml -d $(FLASH_BUILD_TMP)/usb_update.bin
	echo $(BOXTYPE)_$(FLAVOUR)_$(ITYPE)_$(DATE) > $(FLASH_BUILD_TMP)/imageversion
	cd $(FLASH_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multiroot_$(ITYPE)_$(DATE)_emmc.zip apploader.bin bootargs.bin fastboot.bin usb_update.bin imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)

flash-image-$(BOXTYPE)-multi-rootfs:
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(BOXTYPE)
	cp $(RELEASE_DIR)/tmp/uImage $(FLASH_BUILD_TMP)/$(BOXTYPE)/uImage
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar --exclude=uImage* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar
	echo "$(BOXTYPE)_$(FLAVOUR)_multiroot_$(ITYPE)_$(DATE)" > $(FLASH_BUILD_TMP)/$(BOXTYPE)/imageversion
	cd $(FLASH_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multiroot_$(ITYPE)_$(DATE)_mmc.zip $(BOXTYPE)/rootfs.tar.bz2 $(BOXTYPE)/uImage $(BOXTYPE)/imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)

flash-image-$(BOXTYPE)-online:
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(BOXTYPE)
	cp $(RELEASE_DIR)/tmp/uImage $(FLASH_BUILD_TMP)/$(BOXTYPE)/uImage
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar --exclude=uImage* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar
	echo $(BOXTYPE)_$(FLAVOUR)_$(ITYPE)_$(DATE) > $(FLASH_BUILD_TMP)/$(BOXTYPE)/imageversion
	cd $(FLASH_BUILD_TMP)/$(BOXTYPE) && \
	tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multiroot_$(ITYPE)_$(DATE).tgz rootfs.tar.bz2 uImage imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)

$(D)/buildimage-tool: $(ARCHIVE)/$(BUILDIMAGE_SRC)
	install -d $(FLASH_BUILD_TMP)/buildimage
	unzip -o $(ARCHIVE)/$(BUILDIMAGE_SRC) -d $(FLASH_BUILD_TMP)/buildimage
	cd $(FLASH_BUILD_TMP)/buildimage; make; cp $(FLASH_BUILD_TMP)/buildimage/mkupdate $(FLASH_BUILD_TMP)/mkupdate
	$(REMOVE)/buildimage
