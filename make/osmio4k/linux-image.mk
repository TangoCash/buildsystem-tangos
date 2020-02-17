#
# flashimage
#

### Edison Osmio 4K (+)

flashimage:
	$(MAKE) flash-image-osmio4k-multi-disk flash-image-osmio4k-multi-rootfs
	$(TUXBOX_CUSTOMIZE)

ofgimage:
	$(MAKE) ITYPE=ofg flash-image-osmio4k-multi-rootfs
	$(TUXBOX_CUSTOMIZE)

online-image:
	$(MAKE) ITYPE=online flash-image-osmio4k-online
	$(TUXBOX_CUSTOMIZE)

flash-clean:
	echo ""

#
FLASH_BUILD_TMP = $(BUILD_TMP)/image-build
IMAGE_BUILD_DIR = $(BUILD_TMP)/image-build

IMAGE_NAME = emmc
IMAGE_LINK = $(IMAGE_NAME).ext4

# emmc image
EMMC_IMAGE = $(IMAGE_BUILD_DIR)/$(IMAGE_NAME).img
EMMC_IMAGE_SIZE = 7634944

# partition offsets/sizes
IMAGE_ROOTFS_ALIGNMENT = 1024
BOOT_PARTITION_SIZE    = 3072
KERNEL_PARTITION_SIZE  = 8192
ROOTFS_PARTITION_SIZE  = 1767424

KERNEL1_PARTITION_OFFSET = $(shell expr $(IMAGE_ROOTFS_ALIGNMENT)   + $(BOOT_PARTITION_SIZE))
ROOTFS1_PARTITION_OFFSET = $(shell expr $(KERNEL1_PARTITION_OFFSET) + $(KERNEL_PARTITION_SIZE))

KERNEL2_PARTITION_OFFSET = $(shell expr $(ROOTFS1_PARTITION_OFFSET) + $(ROOTFS_PARTITION_SIZE))
ROOTFS2_PARTITION_OFFSET = $(shell expr $(KERNEL2_PARTITION_OFFSET) + $(KERNEL_PARTITION_SIZE))

KERNEL3_PARTITION_OFFSET = $(shell expr $(ROOTFS2_PARTITION_OFFSET) + $(ROOTFS_PARTITION_SIZE))
ROOTFS3_PARTITION_OFFSET = $(shell expr $(KERNEL3_PARTITION_OFFSET) + $(KERNEL_PARTITION_SIZE))

KERNEL4_PARTITION_OFFSET = $(shell expr $(ROOTFS3_PARTITION_OFFSET) + $(ROOTFS_PARTITION_SIZE))
ROOTFS4_PARTITION_OFFSET = $(shell expr $(KERNEL4_PARTITION_OFFSET) + $(KERNEL_PARTITION_SIZE))

SWAP_PARTITION_OFFSET = $(shell expr $(ROOTFS4_PARTITION_OFFSET) + $(ROOTFS_PARTITION_SIZE))

flash-image-osmio4k-multi-disk:
	rm -rf $(IMAGE_BUILD_DIR) || true
	mkdir -p $(IMAGE_BUILD_DIR)/$(BOXTYPE)
	# Create a sparse image block
	dd if=/dev/zero of=$(IMAGE_BUILD_DIR)/$(IMAGE_LINK) seek=$(shell expr $(EMMC_IMAGE_SIZE) \* 1024) count=0 bs=1
	$(HOST_DIR)/bin/mkfs.ext4 -F -m0 $(IMAGE_BUILD_DIR)/$(IMAGE_LINK) -d $(RELEASE_DIR)
	# Error codes 0-3 indicate successfull operation of fsck (no errors or errors corrected)
	$(HOST_DIR)/bin/fsck.ext4 -pfD $(IMAGE_BUILD_DIR)/$(IMAGE_LINK) || [ $? -le 3 ]
	dd if=/dev/zero of=$(EMMC_IMAGE) bs=1 count=0 seek=$(shell expr $(EMMC_IMAGE_SIZE) \* 1024)
	parted -s $(EMMC_IMAGE) mklabel gpt
	parted -s $(EMMC_IMAGE) unit KiB mkpart boot fat16 $(IMAGE_ROOTFS_ALIGNMENT) $(shell expr $(IMAGE_ROOTFS_ALIGNMENT) + $(BOOT_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) set 1 boot on
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel1 $(KERNEL1_PARTITION_OFFSET) $(shell expr $(KERNEL1_PARTITION_OFFSET) + $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs1 ext4 $(ROOTFS1_PARTITION_OFFSET) $(shell expr $(ROOTFS1_PARTITION_OFFSET) + $(ROOTFS_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel2 $(KERNEL2_PARTITION_OFFSET) $(shell expr $(KERNEL2_PARTITION_OFFSET) + $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs2 ext4 $(ROOTFS2_PARTITION_OFFSET) $(shell expr $(ROOTFS2_PARTITION_OFFSET) + $(ROOTFS_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel3 $(KERNEL3_PARTITION_OFFSET) $(shell expr $(KERNEL3_PARTITION_OFFSET) + $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs3 ext4 $(ROOTFS3_PARTITION_OFFSET) $(shell expr $(ROOTFS3_PARTITION_OFFSET) + $(ROOTFS_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel4 $(KERNEL4_PARTITION_OFFSET) $(shell expr $(KERNEL4_PARTITION_OFFSET) + $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs4 ext4 $(ROOTFS4_PARTITION_OFFSET) $(shell expr $(ROOTFS4_PARTITION_OFFSET) + $(ROOTFS_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart swap linux-swap $(SWAP_PARTITION_OFFSET) 100%
	dd if=/dev/zero of=$(IMAGE_BUILD_DIR)/boot.img bs=1024 count=$(BOOT_PARTITION_SIZE)
	mkfs.msdos -n boot -S 512 $(IMAGE_BUILD_DIR)/boot.img
	echo "setenv STARTUP \"boot emmcflash0.kernel1 'root=/dev/mmcblk1p3 rootfstype=ext4 rootwait'\"" > $(IMAGE_BUILD_DIR)/STARTUP
	echo "setenv STARTUP \"boot emmcflash0.kernel1 'root=/dev/mmcblk1p3 rootfstype=ext4 rootwait'\"" > $(IMAGE_BUILD_DIR)/STARTUP_1
	echo "setenv STARTUP \"boot emmcflash0.kernel2 'root=/dev/mmcblk1p5 rootfstype=ext4 rootwait'\"" > $(IMAGE_BUILD_DIR)/STARTUP_2
	echo "setenv STARTUP \"boot emmcflash0.kernel3 'root=/dev/mmcblk1p7 rootfstype=ext4 rootwait'\"" > $(IMAGE_BUILD_DIR)/STARTUP_3
	echo "setenv STARTUP \"boot emmcflash0.kernel4 'root=/dev/mmcblk1p9 rootfstype=ext4 rootwait'\"" > $(IMAGE_BUILD_DIR)/STARTUP_4
	mcopy -i $(IMAGE_BUILD_DIR)/boot.img -v $(IMAGE_BUILD_DIR)/STARTUP ::
	mcopy -i $(IMAGE_BUILD_DIR)/boot.img -v $(IMAGE_BUILD_DIR)/STARTUP_1 ::
	mcopy -i $(IMAGE_BUILD_DIR)/boot.img -v $(IMAGE_BUILD_DIR)/STARTUP_2 ::
	mcopy -i $(IMAGE_BUILD_DIR)/boot.img -v $(IMAGE_BUILD_DIR)/STARTUP_3 ::
	mcopy -i $(IMAGE_BUILD_DIR)/boot.img -v $(IMAGE_BUILD_DIR)/STARTUP_4 ::
	parted -s $(EMMC_IMAGE) unit KiB print
	dd conv=notrunc if=$(IMAGE_BUILD_DIR)/boot.img of=$(EMMC_IMAGE) seek=1 bs=$(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \* 1024)
	dd conv=notrunc if=$(TARGET_DIR)/boot/Image.gz of=$(EMMC_IMAGE) seek=1 bs=$(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \* 1024 + $(BOOT_PARTITION_SIZE) \* 1024)
	$(HOST_DIR)/bin/resize2fs $(IMAGE_BUILD_DIR)/$(IMAGE_LINK) $(ROOTFS_PARTITION_SIZE)k
	# Truncate on purpose
	dd if=$(IMAGE_BUILD_DIR)/$(IMAGE_LINK) of=$(EMMC_IMAGE) seek=1 bs=$(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \* 1024 + $(BOOT_PARTITION_SIZE) \* 1024 + $(KERNEL_PARTITION_SIZE) \* 1024)
	mv $(EMMC_IMAGE) $(IMAGE_BUILD_DIR)/$(BOXTYPE)/

flash-image-osmio4k-multi-rootfs:
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(BOXTYPE)
	cp $(TARGET_DIR)/boot/Image.gz $(IMAGE_BUILD_DIR)/$(BOXTYPE)/kernel.bin
	$(CD) $(RELEASE_DIR); \
		tar -cvf $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.tar . >/dev/null 2>&1; \
		bzip2 $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.tar
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(BOXTYPE)/imageversion
	echo "rename this file to 'force' to force an update without confirmation" > $(IMAGE_BUILD_DIR)/$(BOXTYPE)/noforce; \
	$(CD) $(IMAGE_BUILD_DIR); \
		zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_multi_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').zip $(BOXTYPE)/rootfs.tar.bz2 $(BOXTYPE)/kernel.bin $(BOXTYPE)/$(IMAGE_NAME).img $(BOXTYPE)/imageversion
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)

flash-image-osmio4k-online:
	# Create final USB-image
	rm -rf $(IMAGE_BUILD_DIR) || true
	mkdir -p $(IMAGE_BUILD_DIR)/$(BOXTYPE)
	cp $(TARGET_DIR)/boot/Image.gz $(IMAGE_BUILD_DIR)/$(BOXTYPE)/kernel.bin
	$(CD) $(RELEASE_DIR); \
		tar -cvf $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.tar . >/dev/null 2>&1; \
		bzip2 $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.tar
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(BOXTYPE)/imageversion
	echo "rename this file to 'force' to force an update without confirmation" > $(IMAGE_BUILD_DIR)/$(BOXTYPE)/noforce; \
	$(CD) $(IMAGE_BUILD_DIR)/$(BOXTYPE); \
		tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_multi_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').tgz rootfs.tar.bz2 kernel.bin imageversion
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)
