#
# flashimage
#

### armbox bre2ze4k

flashimage:
	$(MAKE) flash-image-bre2ze4k-multi-disk flash-image-bre2ze4k-multi-rootfs
	$(TUXBOX_CUSTOMIZE)

ofgimage:
	$(MAKE) ITYPE=ofg flash-image-bre2ze4k-multi-rootfs
	$(TUXBOX_CUSTOMIZE)

online-image:
	$(MAKE) ITYPE=online flash-image-bre2ze4k-online
	$(TUXBOX_CUSTOMIZE)

flash-clean:
	echo ""

#
FLASH_BUILD_TMP = $(BUILD_TMP)/image-build

include make/common/gfuture-linux-image.mk
