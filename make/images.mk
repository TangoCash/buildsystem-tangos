#
# flashimage
#

flashimage:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vusolo4k))
ifeq ($(VUPLUS4K_MULTIBOOT), 1)
	$(MAKE) flash-image-vusolo4k-multi-rootfs
else
	$(MAKE) flash-image-vusolo4k-rootfs
endif
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k))
ifeq ($(VUPLUS4K_MULTIBOOT), 1)
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
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vusolo4k))
	$(MAKE) ITYPE=ofg flash-image-vusolo4k-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k))
	$(MAKE) ITYPE=ofg flash-image-vuduo4k-rootfs
endif
	$(TUXBOX_CUSTOMIZE)

oi \
online-image:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vusolo4k))
	$(MAKE) ITYPE=online flash-image-vusolo4k-online
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k))
	$(MAKE) ITYPE=online flash-image-vuduo4k-online
endif
	$(TUXBOX_CUSTOMIZE)

flash-clean:
	echo ""

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
