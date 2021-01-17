#
# flashimage
#

flashimage: $(D)/neutrino
	$(START_BUILD)
	$(MAKE) flash-image-osninoplus
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
	echo "nothing to do"
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

flash-clean:
	echo ""

### mipsbox osninoplus
# general
OSNINO_PREFIX = edision/$(BOXTYPE)
OSNINO_BUILD_TMP = $(BUILD_TMP)/image-build

flash-image-osninoplus:
	rm -rf $(OSNINO_BUILD_TMP) || true
	mkdir -p $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)
	cp $(SKEL_ROOT)/release/splash.bin $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)
	echo "rename this file to 'force' to force an update without confirmation" > $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)/noforce;
	cp $(RELEASE_DIR)/boot/kernel.bin $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)
	mkfs.ubifs -r $(RELEASE_DIR) -o $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)/rootfs.ubi -m 2048 -e 126976 -c 4096 -F
	echo '[ubifs]' > $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)/ubinize.cfg
	echo 'mode=ubi' >> $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)/ubinize.cfg
	echo 'image=$(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)/rootfs.ubi' >> $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)/ubinize.cfg
	echo 'vol_id=0' >> $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)/ubinize.cfg
	echo 'vol_type=dynamic' >> $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)/ubinize.cfg
	echo 'vol_name=rootfs' >> $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)/ubinize.cfg
	echo 'vol_flags=autoresize' >> $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)/ubinize.cfg
	ubinize -o $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)/rootfs.bin -m 2048 -p 128KiB $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)/ubinize.cfg
	rm -f $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)/root.ubi
	rm -f $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)/ubinize.cfg
	echo $(BOXTYPE)_$(FLAVOUR)_$(ITYPE)_$(shell date '+%d%m%Y-%H%M%S') > $(OSNINO_BUILD_TMP)/$(OSNINO_PREFIX)/imageversion
	cd $(OSNINO_BUILD_TMP)/ && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').zip $(OSNINO_PREFIX)*
	# cleanup
	rm -rf $(OSNINO_BUILD_TMP)
