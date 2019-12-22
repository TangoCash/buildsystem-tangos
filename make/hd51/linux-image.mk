#
# flashimage
#

### armbox hd51

flashimage:
	$(MAKE) flash-image-hd51-multi-disk flash-image-hd51-multi-rootfs
	$(TUXBOX_CUSTOMIZE)

ofgimage:
	$(MAKE) ITYPE=ofg flash-image-hd51-multi-rootfs
	$(TUXBOX_CUSTOMIZE)

online-image:
	$(MAKE) ITYPE=online flash-image-hd51-online
	$(TUXBOX_CUSTOMIZE)

flash-clean:
	echo ""

#
FLASH_BUILD_TMP = $(BUILD_TMP)/image-build

include make/common/gfuture-linux-image.mk
