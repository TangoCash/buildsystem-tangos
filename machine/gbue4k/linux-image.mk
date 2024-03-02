#
# flashimage
#

### armbox gbue4k

flashimage: $(D)/neutrino
	$(START_BUILD)
	$(MAKE) flash-image-gbue4k
	$(TUXBOX_CUSTOMIZE)
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

ofgimage: $(D)/neutrino
	$(START_BUILD)
	$(START_BUILD)
	echo "nothing to do"
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

online-image: $(D)/neutrino
	$(START_BUILD)
	$(MAKE) ITYPE=online flash-image-gbue4k-online
	$(TUXBOX_CUSTOMIZE)
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

flash-clean:
	echo ""

#
# general
FLASH_BUILD_TMP = $(BUILD_TMP)/image-build
BRAND = gigablue
IMAGE_SUBDIR = $(BRAND)/$(BOXTYPE)
INITRD_SRCDATE = 20181121r1
INITRD_SRC = initrd_${BOXTYPE}_${INITRD_SRCDATE}.zip

$(ARCHIVE)/$(INITRD_SRC):
	$(DOWNLOAD) https://source.mynonpublic.com/$(BRAND)/initrd/$(INITRD_SRC)

flash-image-gbue4k: $(ARCHIVE)/$(INITRD_SRC)
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)
	unzip -o $(ARCHIVE)/$(INITRD_SRC) -d $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)
	cp $(RELEASE_DIR)/boot/zImage $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/kernel.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs.tar --exclude=kernel.bin . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs.tar
	echo "$(BOXTYPE)_$(FLAVOUR)_$(ITYPE)_$(DATE)" > $(FLASH_BUILD_TMP)/$(IMAGE_SUBDIR)/imageversion
	cd $(FLASH_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_$(ITYPE)_$(DATE)_usb.zip $(BRAND)
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)
