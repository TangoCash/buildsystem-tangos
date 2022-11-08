# general
FLASH_IMAGE_NAME = disk
FLASH_BOOT_IMAGE = boot.img
FLASH_IMAGE_LINK = $(FLASH_IMAGE_NAME).ext4
FLASH_IMAGE_ROOTFS_SIZE = 294912

ifeq ($(BOXTYPE),$(filter $(BOXTYPE),bre2ze4k hd51 protek4k))
IMAGE_SUBDIR = $(BOXTYPE)
endif
ifeq ($(BOXTYPE),e4hdultra)
IMAGE_SUBDIR = e4hd
endif
ifeq ($(BOXTYPE),h7)
IMAGE_SUBDIR = zgemma/$(BOXTYPE)
endif

# emmc image
EMMC_IMAGE_SIZE = 3817472
EMMC_IMAGE = $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_NAME).img

# partition sizes
BLOCK_SIZE = 512
BLOCK_SECTOR = 2
IMAGE_ROOTFS_ALIGNMENT = 1024
BOOT_PARTITION_SIZE = 3072
KERNEL_PARTITION_SIZE = 8192
SWAP_PARTITION_SIZE = 262144
# partition size single
# without storage partition 819200 each
# 51200 * 4
STORAGE_PARTITION_SIZE = 204800
ROOTFS_PARTITION_SINGLE_SIZE = 768000
# linuxrootfs1
ROOTFS_PARTITION_MULTI_SIZE = 1048576
# linuxrootfs2-4
# MULTI_ROOTFS_PARTITION_SIZE = 2468864 - 204800 = 2264064
ALL_KERNEL_SIZE = $(shell expr 4 \* $(KERNEL_PARTITION_SIZE))
MULTI_ROOTFS_PARTITION_SIZE = $(shell expr $(EMMC_IMAGE_SIZE) \- $(BLOCK_SECTOR) \* $(IMAGE_ROOTFS_ALIGNMENT) \- $(BOOT_PARTITION_SIZE) \- $(ALL_KERNEL_SIZE) \- $(ROOTFS_PARTITION_MULTI_SIZE) \- $(SWAP_PARTITION_SIZE) \- $(STORAGE_PARTITION_SIZE))

KERNEL_PARTITION_OFFSET = $(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \+ $(BOOT_PARTITION_SIZE))
ROOTFS_PARTITION_OFFSET = $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

#calc the offsets (single)
SECOND_KERNEL_PARTITION_OFFSET = $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SINGLE_SIZE))
SECOND_ROOTFS_PARTITION_OFFSET = $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
THIRD_KERNEL_PARTITION_OFFSET = $(shell expr $(SECOND_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SINGLE_SIZE))
THIRD_ROOTFS_PARTITION_OFFSET = $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
FOURTH_KERNEL_PARTITION_OFFSET = $(shell expr $(THIRD_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SINGLE_SIZE))
FOURTH_ROOTFS_PARTITION_OFFSET = $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
SWAP_PARTITION_OFFSET = $(shell expr $(FOURTH_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SINGLE_SIZE))
STORAGE_PARTITION_OFFSET = $(shell expr $(SWAP_PARTITION_OFFSET) \+ $(SWAP_PARTITION_SIZE))

#calc the offsets (multi)
SECOND_KERNEL_PARTITION_OFFSET_NL = $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_MULTI_SIZE))
THIRD_KERNEL_PARTITION_OFFSET_NL = $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET_NL) \+ $(KERNEL_PARTITION_SIZE))
FOURTH_KERNEL_PARTITION_OFFSET_NL = $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET_NL) \+ $(KERNEL_PARTITION_SIZE))
SWAP_PARTITION_OFFSET_NL = $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET_NL) \+ $(KERNEL_PARTITION_SIZE))
MULTI_ROOTFS_PARTITION_OFFSET = $(shell expr $(SWAP_PARTITION_OFFSET_NL) \+ $(SWAP_PARTITION_SIZE))
STORAGE_PARTITION_OFFSET_NL = $(shell expr $(MULTI_ROOTFS_PARTITION_OFFSET) \+ $(MULTI_ROOTFS_PARTITION_SIZE))

flash-image-$(BOXTYPE)-multi-disk: $(D)/host_resize2fs $(D)/host_parted
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(BOXTYPE)
	# move kernel files from $(RELEASE_DIR)/boot to $(FLASH_BUILD_TMP)
	mv -f $(RELEASE_DIR)/boot/zImage* $(FLASH_BUILD_TMP)/
	# Create a sparse image block
	dd if=/dev/zero of=$(FLASH_BUILD_TMP)/$(FLASH_IMAGE_LINK) seek=$(shell expr $(FLASH_IMAGE_ROOTFS_SIZE) \* $(BLOCK_SECTOR)) count=0 bs=$(BLOCK_SIZE)
ifeq ($(LAYOUT), multi)
	$(HOST_DIR)/bin/mkfs.ext4 -F $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_LINK) -d $(RELEASE_DIR)/..
else
	$(HOST_DIR)/bin/mkfs.ext4 -F $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_LINK) -d $(RELEASE_DIR)
endif
	# move kernel files back to $(RELEASE_DIR)/boot
	mv -f $(FLASH_BUILD_TMP)/zImage* $(RELEASE_DIR)/boot/
	# Error codes 0-3 indicate successfull operation of fsck (no errors or errors corrected)
	$(HOST_DIR)/bin/fsck.ext4 -pvfD $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_LINK) || [ $? -le 3 ]
	dd if=/dev/zero of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) count=0 seek=$(shell expr $(EMMC_IMAGE_SIZE) \* $(BLOCK_SECTOR))
	parted -s $(EMMC_IMAGE) mklabel gpt
	parted -s $(EMMC_IMAGE) unit KiB mkpart boot fat16 $(IMAGE_ROOTFS_ALIGNMENT) $(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \+ $(BOOT_PARTITION_SIZE))
ifeq ($(LAYOUT), multi)
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel $(KERNEL_PARTITION_OFFSET) $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxrootfs ext4 $(ROOTFS_PARTITION_OFFSET) $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_MULTI_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel2 $(SECOND_KERNEL_PARTITION_OFFSET_NL) $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET_NL) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel3 $(THIRD_KERNEL_PARTITION_OFFSET_NL) $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET_NL) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel4 $(FOURTH_KERNEL_PARTITION_OFFSET_NL) $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET_NL) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart swap linux-swap $(SWAP_PARTITION_OFFSET_NL) $(shell expr $(SWAP_PARTITION_OFFSET_NL) \+ $(SWAP_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart userdata ext4 $(MULTI_ROOTFS_PARTITION_OFFSET) $(shell expr $(MULTI_ROOTFS_PARTITION_OFFSET) \+ $(MULTI_ROOTFS_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart storage ext4 $(STORAGE_PARTITION_OFFSET_NL) 100%
	dd if=/dev/zero of=$(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) bs=$(BLOCK_SIZE) count=$(shell expr $(BOOT_PARTITION_SIZE) \* $(BLOCK_SECTOR))
	mkfs.msdos -S 512 $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE)
ifeq ($(BOXTYPE),$(filter $(BOXTYPE),e4hdultra protek4k))
		echo "boot emmcflash0.linuxkernel 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p3 rootsubdir=linuxrootfs1 kernel=/dev/mmcblk0p2 rw rootwait $(BOXTYPE)_4.boxmode=5'" > $(FLASH_BUILD_TMP)/STARTUP
		echo "boot emmcflash0.linuxkernel 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p3 rootsubdir=linuxrootfs1 kernel=/dev/mmcblk0p2 rw rootwait $(BOXTYPE)_4.boxmode=5'" > $(FLASH_BUILD_TMP)/STARTUP_1
		echo "boot emmcflash0.linuxkernel2 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p8 rootsubdir=linuxrootfs2 kernel=/dev/mmcblk0p4 rw rootwait $(BOXTYPE)_4.boxmode=5'" > $(FLASH_BUILD_TMP)/STARTUP_2
		echo "boot emmcflash0.linuxkernel3 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p8 rootsubdir=linuxrootfs3 kernel=/dev/mmcblk0p5 rw rootwait $(BOXTYPE)_4.boxmode=5'" > $(FLASH_BUILD_TMP)/STARTUP_3
		echo "boot emmcflash0.linuxkernel4 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p8 rootsubdir=linuxrootfs4 kernel=/dev/mmcblk0p6 rw rootwait $(BOXTYPE)_4.boxmode=5'" > $(FLASH_BUILD_TMP)/STARTUP_4
else
		echo "boot emmcflash0.linuxkernel 'root=/dev/mmcblk0p3 rootsubdir=linuxrootfs1 kernel=/dev/mmcblk0p2 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP
		echo "boot emmcflash0.linuxkernel 'root=/dev/mmcblk0p3 rootsubdir=linuxrootfs1 kernel=/dev/mmcblk0p2 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_1
		echo "boot emmcflash0.linuxkernel2 'root=/dev/mmcblk0p8 rootsubdir=linuxrootfs2 kernel=/dev/mmcblk0p4 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_2
		echo "boot emmcflash0.linuxkernel3 'root=/dev/mmcblk0p8 rootsubdir=linuxrootfs3 kernel=/dev/mmcblk0p5 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_3
		echo "boot emmcflash0.linuxkernel4 'root=/dev/mmcblk0p8 rootsubdir=linuxrootfs4 kernel=/dev/mmcblk0p6 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_4
endif
else
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel1 $(KERNEL_PARTITION_OFFSET) $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs1 ext4 $(ROOTFS_PARTITION_OFFSET) $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SINGLE_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel2 $(SECOND_KERNEL_PARTITION_OFFSET) $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs2 ext4 $(SECOND_ROOTFS_PARTITION_OFFSET) $(shell expr $(SECOND_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SINGLE_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel3 $(THIRD_KERNEL_PARTITION_OFFSET) $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs3 ext4 $(THIRD_ROOTFS_PARTITION_OFFSET) $(shell expr $(THIRD_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SINGLE_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel4 $(FOURTH_KERNEL_PARTITION_OFFSET) $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs4 ext4 $(FOURTH_ROOTFS_PARTITION_OFFSET) $(shell expr $(FOURTH_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SINGLE_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart swap linux-swap $(SWAP_PARTITION_OFFSET) $(shell expr $(SWAP_PARTITION_OFFSET) \+ $(SWAP_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart storage ext4 $(STORAGE_PARTITION_OFFSET) 100%
	dd if=/dev/zero of=$(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) bs=$(BLOCK_SIZE) count=$(shell expr $(BOOT_PARTITION_SIZE) \* $(BLOCK_SECTOR))
	mkfs.msdos -S 512 $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE)
ifeq ($(BOXTYPE),$(filter $(BOXTYPE),e4hdultra protek4k))
		echo "boot emmcflash0.kernel1 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p3 rw rootwait $(BOXTYPE)_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP
		echo "boot emmcflash0.kernel1 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p3 rw rootwait $(BOXTYPE)_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_1
		echo "boot emmcflash0.kernel2 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p5 rw rootwait $(BOXTYPE)_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_2
		echo "boot emmcflash0.kernel3 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p7 rw rootwait $(BOXTYPE)_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_3
		echo "boot emmcflash0.kernel4 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p9 rw rootwait $(BOXTYPE)_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_4
else
		echo "boot emmcflash0.kernel1 'brcm_cma=440M@328M brcm_cma=192M@768M root=/dev/mmcblk0p3 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP
		echo "boot emmcflash0.kernel1 'brcm_cma=440M@328M brcm_cma=192M@768M root=/dev/mmcblk0p3 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_1
		echo "boot emmcflash0.kernel2 'brcm_cma=440M@328M brcm_cma=192M@768M root=/dev/mmcblk0p5 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_2
		echo "boot emmcflash0.kernel3 'brcm_cma=440M@328M brcm_cma=192M@768M root=/dev/mmcblk0p7 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_3
		echo "boot emmcflash0.kernel4 'brcm_cma=440M@328M brcm_cma=192M@768M root=/dev/mmcblk0p9 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_4
endif
endif
	mcopy -i $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP ::
	mcopy -i $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_1 ::
	mcopy -i $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_2 ::
	mcopy -i $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_3 ::
	mcopy -i $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_4 ::
ifeq ($(BOXTYPE),$(filter $(BOXTYPE),e4hdultra protek4k))
	mcopy -i $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) -v $(MACHINE_FILES)/lcdsplash.bmp ::
endif
	dd conv=notrunc if=$(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \* $(BLOCK_SECTOR))
ifneq ($(KERNEL_DTB_VER),)
	dd conv=notrunc if=$(RELEASE_DIR)/boot/$(KERNEL_IMAGE).dtb of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(KERNEL_PARTITION_OFFSET) \* $(BLOCK_SECTOR))
else
	dd conv=notrunc if=$(RELEASE_DIR)/boot/$(KERNEL_IMAGE) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(KERNEL_PARTITION_OFFSET) \* $(BLOCK_SECTOR))
endif
ifeq ($(LAYOUT), multi)
	$(HOST_DIR)/bin/resize2fs $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_LINK) $(ROOTFS_PARTITION_MULTI_SIZE)k
else
	$(HOST_DIR)/bin/resize2fs $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_LINK) $(ROOTFS_PARTITION_SINGLE_SIZE)k
endif
	# Truncate on purpose
	dd if=$(FLASH_BUILD_TMP)/$(FLASH_IMAGE_LINK) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(ROOTFS_PARTITION_OFFSET) \* $(BLOCK_SECTOR)) count=$(shell expr $(FLASH_IMAGE_ROOTFS_SIZE) \* $(BLOCK_SECTOR))
	mv $(FLASH_BUILD_TMP)/disk.img $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/

flash-image-$(BOXTYPE)-multi-rootfs:
	mkdir -p $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)
ifneq ($(KERNEL_DTB_VER),)
	cp $(RELEASE_DIR)/boot/$(KERNEL_IMAGE).dtb $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/kernel.bin
else
	cp $(RELEASE_DIR)/boot/$(KERNEL_IMAGE) $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/kernel.bin
endif
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs.tar --exclude=zImage* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs.tar
	echo $(BOXTYPE)_$(FLAVOUR)_multiroot_$(ITYPE)_$(DATE) > $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/imageversion
	# lcd flashlogo for e4hdultra/protek4k
ifeq ($(BOXTYPE),$(filter $(BOXTYPE),e4hdultra protek4k))
	cp $(MACHINE_FILES)/lcdflashing.bmp $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/
	ADDITIONAL_FILES=$(IMAGE_SUBDIR)/lcdflashing.bmp
endif
	cd $(FLASH_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_$(LAYOUT)_$(ITYPE)_$(DATE).zip $(IMAGE_SUBDIR)/rootfs.tar.bz2 $(IMAGE_SUBDIR)/kernel.bin $(IMAGE_SUBDIR)/disk.img $(IMAGE_SUBDIR)/imageversion $(ADDITIONAL_FILES)
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)

flash-image-$(BOXTYPE)-online:
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)
ifneq ($(KERNEL_DTB_VER),)
	cp $(RELEASE_DIR)/boot/$(KERNEL_IMAGE).dtb $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/kernel.bin
else
	cp $(RELEASE_DIR)/boot/$(KERNEL_IMAGE) $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/kernel.bin
endif
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs.tar --exclude=zImage* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs.tar
	echo $(BOXTYPE)_$(FLAVOUR)_$(ITYPE)_$(DATE) > $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/imageversion
	cd $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR) && \
	tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_$(LAYOUT)_$(ITYPE)_$(DATE).tgz rootfs.tar.bz2 kernel.bin imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)
