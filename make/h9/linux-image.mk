#
# flashimage
#

### armbox h9

flashimage: $(D)/neutrino
	$(START_BUILD)
	$(MAKE) flash-image-h9 flash-image-h9-online
	$(TUXBOX_CUSTOMIZE)
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

ofgimage: $(D)/neutrino
	$(START_BUILD)
	echo "nothing to do"
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

online-image: $(D)/neutrino
	$(START_BUILD)
	$(MAKE) ITYPE=online flash-image-h9-online
	$(TUXBOX_CUSTOMIZE)
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

flash-clean:
	echo ""

# general
FLASH_PREFIX = $(BOXTYPE)
FLASH_BUILD_TMP = $(BUILD_TMP)/image-build

HICHIPSET = 3798mv200
BOOTARGS_DATE = 20200916
BOOTARGS_SRC = zgemma-bootargs-$(HICHIPSET)-$(BOOTARGS_DATE).zip

FASTBOOT_DATE = 20200916
FASTBOOT_SRC = zgemma-fastboot-$(HICHIPSET)-$(FASTBOOT_DATE).zip

PARAM_DATE = 20190530
PARAM_SRC = zgemma-param-$(HICHIPSET)-$(PARAM_DATE).zip

$(ARCHIVE)/$(BOOTARGS_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/zgemma/$(BOOTARGS_SRC)

$(ARCHIVE)/$(FASTBOOT_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/zgemma/$(FASTBOOT_SRC)

$(ARCHIVE)/$(PARAM_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/zgemma/$(PARAM_SRC)

flash-image-h9: $(ARCHIVE)/$(BOOTARGS_SRC) $(ARCHIVE)/$(FASTBOOT_SRC) $(ARCHIVE)/$(PARAM_SRC)
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)
	$(MAKE) install-bootargs
	$(MAKE) install-fastboot
	$(MAKE) install-param
#	cp $(SKEL_ROOT)/release/splash.bin $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)
	echo "rename this file to 'force' to force an update without confirmation" > $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/noforce;
	cp $(RELEASE_DIR)/tmp/uImage $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)
	mkfs.ubifs -r $(RELEASE_DIR) -o $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/ubifs.img -m 2048 -e 126976 -c 4096
	echo '[ubifs]' > $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/ubinize.cfg
	echo 'mode=ubi' >> $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/ubinize.cfg
	echo 'image=$(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/ubifs.img' >> $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/ubinize.cfg
	echo 'vol_id=0' >> $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/ubinize.cfg
	echo 'vol_type=dynamic' >> $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/ubinize.cfg
	echo 'vol_name=rootfs' >> $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/ubinize.cfg
	echo 'vol_flags=autoresize' >> $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/ubinize.cfg
	ubinize -o $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/rootfs.ubi -m 2048 -p 128KiB $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/ubinize.cfg
	rm -f $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/ubifs.img
	rm -f $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/ubinize.cfg
	echo $(BOXTYPE)_$(FLAVOUR)_$(ITYPE)_$(shell date '+%d%m%Y-%H%M%S') > $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/imageversion
	install -m 0644 $(SKEL_ROOT)/release/logo.img $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/logo.img
	cd $(FLASH_BUILD_TMP)/ && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').zip $(FLASH_PREFIX)* fastboot.bin bootargs.bin
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)

flash-image-h9-online:
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

$(D)/install-bootargs: $(ARCHIVE)/$(BOOTARGS_SRC)
	install -d $(FLASH_BUILD_TMP)/bootargs
	unzip -o $(ARCHIVE)/$(BOOTARGS_SRC) -d $(FLASH_BUILD_TMP)/bootargs
	install -m 0644 $(FLASH_BUILD_TMP)/bootargs/bootargs_h9.bin $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/bootargs.bin
	install -m 0644 $(FLASH_BUILD_TMP)/bootargs/rescue_bootargs_h9.bin $(FLASH_BUILD_TMP)/bootargs.bin

$(D)/install-fastboot: $(ARCHIVE)/$(FASTBOOT_SRC)
	install -d $(FLASH_BUILD_TMP)/fastboot
	unzip -o $(ARCHIVE)/$(FASTBOOT_SRC) -d $(FLASH_BUILD_TMP)/fastboot
	install -m 0644 $(FLASH_BUILD_TMP)/fastboot/fastboot_h9.bin $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/fastboot.bin
	install -m 0644 $(FLASH_BUILD_TMP)/fastboot/rescue_fastboot_h9.bin $(FLASH_BUILD_TMP)/fastboot.bin

$(D)/install-param: $(ARCHIVE)/$(PARAM_SRC)
	install -d $(FLASH_BUILD_TMP)/param
	unzip -o $(ARCHIVE)/$(PARAM_SRC) -d $(FLASH_BUILD_TMP)/param
	install -m 0644 $(FLASH_BUILD_TMP)/param/baseparam.img $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/baseparam.img
	install -m 0644 $(FLASH_BUILD_TMP)/param/pq_param.bin $(FLASH_BUILD_TMP)/$(FLASH_PREFIX)/pq_param.bin
