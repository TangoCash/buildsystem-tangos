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

#
FLASH_BUILD_TMP = $(BUILD_TMP)/image-build

include make/common/gfuture-linux-image.mk
