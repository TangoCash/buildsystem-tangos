#
# flashimage
#

### armbox h7

flashimage:
	$(MAKE) flash-image-h7-multi-disk flash-image-h7-multi-rootfs
	$(TUXBOX_CUSTOMIZE)

ofgimage:
	$(MAKE) ITYPE=ofg flash-image-h7-multi-rootfs
	$(TUXBOX_CUSTOMIZE)

online-image:
	$(MAKE) ITYPE=online flash-image-h7-online
	$(TUXBOX_CUSTOMIZE)

flash-clean:
	echo ""

# general
FLASH_IMAGE_NAME = disk
FLASH_BOOT_IMAGE = boot.img
FLASH_IMAGE_LINK = $(FLASH_IMAGE_NAME).ext4
FLASH_IMAGE_ROOTFS_SIZE = 294912
FLASH_BUILD_TMP = $(BUILD_TMP)/image-build

# emmc image
EMMC_IMAGE_SIZE = 3817472
EMMC_IMAGE = $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_NAME).img

# partition sizes
BLOCK_SIZE = 512
BLOCK_SECTOR = 2
IMAGE_ROOTFS_ALIGNMENT = 1024
BOOT_PARTITION_SIZE = 3072
KERNEL_PARTITION_OFFSET = $(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \+ $(BOOT_PARTITION_SIZE))
KERNEL_PARTITION_SIZE = 8192
ROOTFS_PARTITION_OFFSET = $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

# partition sizes multi
# without swap data partition 819200
ROOTFS_PARTITION_SIZE_MULTI = 768000
ROOTFS_PARTITION_SIZE_MULTI_NL = 1048576
# 51200 * 4
SWAP_DATA_PARTITION_SIZE = 204800

SECOND_KERNEL_PARTITION_OFFSET = $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
SECOND_ROOTFS_PARTITION_OFFSET = $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
SECOND_KERNEL_PARTITION_OFFSET_NL = "$(shell expr ${ROOTFS_PARTITION_OFFSET} \+ ${ROOTFS_PARTITION_SIZE_MULTI_NL})"

THIRD_KERNEL_PARTITION_OFFSET = $(shell expr $(SECOND_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
THIRD_ROOTFS_PARTITION_OFFSET = $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
THIRD_KERNEL_PARTITION_OFFSET_NL = "$(shell expr ${SECOND_KERNEL_PARTITION_OFFSET_NL} \+ ${KERNEL_PARTITION_SIZE})"

FOURTH_KERNEL_PARTITION_OFFSET = $(shell expr $(THIRD_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
FOURTH_ROOTFS_PARTITION_OFFSET = $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
FOURTH_KERNEL_PARTITION_OFFSET_NL = "$(shell expr ${THIRD_KERNEL_PARTITION_OFFSET_NL} \+ ${KERNEL_PARTITION_SIZE})"

SWAP_DATA_PARTITION_OFFSET = $(shell expr $(FOURTH_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))

SWAP_PARTITION_OFFSET = $(shell expr $(SWAP_DATA_PARTITION_OFFSET) \+ $(SWAP_DATA_PARTITION_SIZE))

MULTI_ROOTFS_PARTITION_OFFSET = "$(shell expr ${FOURTH_KERNEL_PARTITION_OFFSET_NL} \+ ${KERNEL_PARTITION_SIZE})"

flash-image-h7-multi-disk: $(D)/host_resize2fs
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(BOXTYPE)
	# move kernel files from $(RELEASE_DIR)/boot to $(FLASH_BUILD_TMP)
	mv -f $(RELEASE_DIR)/boot/zImage* $(FLASH_BUILD_TMP)/
	# Create a sparse image block
	dd if=/dev/zero of=$(FLASH_BUILD_TMP)/$(FLASH_IMAGE_LINK) seek=$(shell expr $(FLASH_IMAGE_ROOTFS_SIZE) \* $(BLOCK_SECTOR)) count=0 bs=$(BLOCK_SIZE)
ifeq ($(NEWLAYOUT), $(filter $(NEWLAYOUT), 1))
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
ifeq ($(NEWLAYOUT), $(filter $(NEWLAYOUT), 1))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel $(KERNEL_PARTITION_OFFSET) $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxrootfs ext4 $(ROOTFS_PARTITION_OFFSET) $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI_NL))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel2 $(SECOND_KERNEL_PARTITION_OFFSET_NL) $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET_NL) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel3 $(THIRD_KERNEL_PARTITION_OFFSET_NL) $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET_NL) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel4 $(FOURTH_KERNEL_PARTITION_OFFSET_NL) $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET_NL) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart userdata ext4 ${MULTI_ROOTFS_PARTITION_OFFSET} 100%
	dd if=/dev/zero of=$(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) bs=$(BLOCK_SIZE) count=$(shell expr $(BOOT_PARTITION_SIZE) \* $(BLOCK_SECTOR))
	mkfs.msdos -S 512 $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE)
	echo "boot emmcflash0.linuxkernel 'root=/dev/mmcblk0p3 rootsubdir=linuxrootfs1 kernel=/dev/mmcblk0p2 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP
	echo "boot emmcflash0.linuxkernel 'root=/dev/mmcblk0p3 rootsubdir=linuxrootfs1 kernel=/dev/mmcblk0p2 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_1
	echo "boot emmcflash0.linuxkernel2 'root=/dev/mmcblk0p7 rootsubdir=linuxrootfs2 kernel=/dev/mmcblk0p4 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_2
	echo "boot emmcflash0.linuxkernel3 'root=/dev/mmcblk0p7 rootsubdir=linuxrootfs3 kernel=/dev/mmcblk0p5 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_3
	echo "boot emmcflash0.linuxkernel4 'root=/dev/mmcblk0p7 rootsubdir=linuxrootfs4 kernel=/dev/mmcblk0p6 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_4
	echo "boot emmcflash0.linuxkernel 'brcm_cma=520M@248M brcm_cma=192M@768M root=/dev/mmcblk0p3 rootsubdir=linuxrootfs1 kernel=/dev/mmcblk0p2 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(FLASH_BUILD_TMP)/STARTUP_1_12
	echo "boot emmcflash0.linuxkernel2 'brcm_cma=520M@248M brcm_cma=192M@768M root=/dev/mmcblk0p7 rootsubdir=linuxrootfs2 kernel=/dev/mmcblk0p4 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(FLASH_BUILD_TMP)/STARTUP_2_12
	echo "boot emmcflash0.linuxkernel3 'brcm_cma=520M@248M brcm_cma=192M@768M root=/dev/mmcblk0p7 rootsubdir=linuxrootfs3 kernel=/dev/mmcblk0p5 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(FLASH_BUILD_TMP)/STARTUP_3_12
	echo "boot emmcflash0.linuxkernel4 'brcm_cma=520M@248M brcm_cma=192M@768M root=/dev/mmcblk0p7 rootsubdir=linuxrootfs4 kernel=/dev/mmcblk0p6 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(FLASH_BUILD_TMP)/STARTUP_4_12
else
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel1 $(KERNEL_PARTITION_OFFSET) $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs1 ext4 $(ROOTFS_PARTITION_OFFSET) $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel2 $(SECOND_KERNEL_PARTITION_OFFSET) $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs2 ext4 $(SECOND_ROOTFS_PARTITION_OFFSET) $(shell expr $(SECOND_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel3 $(THIRD_KERNEL_PARTITION_OFFSET) $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs3 ext4 $(THIRD_ROOTFS_PARTITION_OFFSET) $(shell expr $(THIRD_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel4 $(FOURTH_KERNEL_PARTITION_OFFSET) $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs4 ext4 $(FOURTH_ROOTFS_PARTITION_OFFSET) $(shell expr $(FOURTH_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
	parted -s $(EMMC_IMAGE) unit KiB mkpart swap linux-swap $(SWAP_DATA_PARTITION_OFFSET) $(shell expr $(SWAP_DATA_PARTITION_OFFSET) \+ $(SWAP_DATA_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart swapdata ext4 $(SWAP_PARTITION_OFFSET) $(shell expr $(EMMC_IMAGE_SIZE) \- 1024)
	dd if=/dev/zero of=$(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) bs=$(BLOCK_SIZE) count=$(shell expr $(BOOT_PARTITION_SIZE) \* $(BLOCK_SECTOR))
	mkfs.msdos -S 512 $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE)
	echo "boot emmcflash0.kernel1 'brcm_cma=440M@328M brcm_cma=192M@768M root=/dev/mmcblk0p3 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP
	echo "boot emmcflash0.kernel1 'brcm_cma=440M@328M brcm_cma=192M@768M root=/dev/mmcblk0p3 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_1
	echo "boot emmcflash0.kernel2 'brcm_cma=440M@328M brcm_cma=192M@768M root=/dev/mmcblk0p5 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_2
	echo "boot emmcflash0.kernel3 'brcm_cma=440M@328M brcm_cma=192M@768M root=/dev/mmcblk0p7 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_3
	echo "boot emmcflash0.kernel4 'brcm_cma=440M@328M brcm_cma=192M@768M root=/dev/mmcblk0p9 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(FLASH_BUILD_TMP)/STARTUP_4
	echo "boot emmcflash0.kernel1 'brcm_cma=520M@248M brcm_cma=200M@768M root=/dev/mmcblk0p3 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(FLASH_BUILD_TMP)/STARTUP_1_12
	echo "boot emmcflash0.kernel2 'brcm_cma=520M@248M brcm_cma=200M@768M root=/dev/mmcblk0p5 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(FLASH_BUILD_TMP)/STARTUP_2_12
	echo "boot emmcflash0.kernel3 'brcm_cma=520M@248M brcm_cma=200M@768M root=/dev/mmcblk0p7 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(FLASH_BUILD_TMP)/STARTUP_3_12
	echo "boot emmcflash0.kernel4 'brcm_cma=520M@248M brcm_cma=200M@768M root=/dev/mmcblk0p9 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(FLASH_BUILD_TMP)/STARTUP_4_12
endif
	mcopy -i $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP ::
	mcopy -i $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_1 ::
	mcopy -i $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_2 ::
	mcopy -i $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_3 ::
	mcopy -i $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_4 ::
	mcopy -i $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_1_12 ::
	mcopy -i $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_2_12 ::
	mcopy -i $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_3_12 ::
	mcopy -i $(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_4_12 ::
	dd conv=notrunc if=$(FLASH_BUILD_TMP)/$(FLASH_BOOT_IMAGE) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \* $(BLOCK_SECTOR))
	dd conv=notrunc if=$(RELEASE_DIR)/boot/zImage.dtb of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(KERNEL_PARTITION_OFFSET) \* $(BLOCK_SECTOR))
ifeq ($(NEWLAYOUT), $(filter $(NEWLAYOUT), 1))
	$(HOST_DIR)/bin/resize2fs $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_LINK) $(ROOTFS_PARTITION_SIZE_MULTI_NL)k
else
	$(HOST_DIR)/bin/resize2fs $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_LINK) $(ROOTFS_PARTITION_SIZE_MULTI)k
endif
	# Truncate on purpose
	dd if=$(FLASH_BUILD_TMP)/$(FLASH_IMAGE_LINK) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(ROOTFS_PARTITION_OFFSET) \* $(BLOCK_SECTOR)) count=$(shell expr $(FLASH_IMAGE_ROOTFS_SIZE) \* $(BLOCK_SECTOR))
	mv $(FLASH_BUILD_TMP)/disk.img $(FLASH_BUILD_TMP)/$(BOXTYPE)/

flash-image-h7-multi-rootfs:
	mkdir -p $(FLASH_BUILD_TMP)/$(BOXTYPE)
	cp $(RELEASE_DIR)/boot/zImage.dtb $(FLASH_BUILD_TMP)/$(BOXTYPE)/kernel.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar --exclude=zImage* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(FLASH_BUILD_TMP)/$(BOXTYPE)/imageversion
	cd $(FLASH_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_multi_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').zip $(BOXTYPE)/rootfs.tar.bz2 $(BOXTYPE)/kernel.bin $(BOXTYPE)/disk.img $(BOXTYPE)/imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)

flash-image-h7-online:
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(BOXTYPE)
	cp $(RELEASE_DIR)/boot/zImage.dtb $(FLASH_BUILD_TMP)/$(BOXTYPE)/kernel.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar --exclude=zImage* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(FLASH_BUILD_TMP)/$(BOXTYPE)/imageversion
	cd $(FLASH_BUILD_TMP)/$(BOXTYPE) && \
	tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_multi_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').tgz rootfs.tar.bz2 kernel.bin imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)
