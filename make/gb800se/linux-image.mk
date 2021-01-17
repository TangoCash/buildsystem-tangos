#
# flashimage
#

flashimage: $(D)/neutrino
	$(START_BUILD)
	$(MAKE) flash-image-gb800se
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

### mipsbox gb800se
# general
GB800SE_PREFIX = gigablue/se
GB800SE_BUILD_TMP = $(BUILD_TMP)/image-build

flash-image-gb800se:
	rm -rf $(GB800SE_BUILD_TMP) || true
	mkdir -p $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)
	cp $(SKEL_ROOT)/release/splash.bin $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)
	echo "rename this file to 'force' to force an update without confirmation" > $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)/noforce;
	cp $(RELEASE_DIR)/boot/kernel.bin $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)
	mkfs.ubifs -r $(RELEASE_DIR) -o $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)/rootfs.ubi -m 2048 -e 126976 -c 4096 -F
	echo '[ubifs]' > $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)/ubinize.cfg
	echo 'mode=ubi' >> $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)/ubinize.cfg
	echo 'image=$(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)/rootfs.ubi' >> $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)/ubinize.cfg
	echo 'vol_id=0' >> $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)/ubinize.cfg
	echo 'vol_type=dynamic' >> $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)/ubinize.cfg
	echo 'vol_name=rootfs' >> $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)/ubinize.cfg
	echo 'vol_flags=autoresize' >> $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)/ubinize.cfg
	ubinize -o $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)/rootfs.bin -m 2048 -p 128KiB $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)/ubinize.cfg
	rm -f $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)/root.ubi
	rm -f $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)/ubinize.cfg
	echo $(BOXTYPE)_$(FLAVOUR)_$(ITYPE)_$(shell date '+%d%m%Y-%H%M%S') > $(GB800SE_BUILD_TMP)/$(GB800SE_PREFIX)/imageversion
	cd $(GB800SE_BUILD_TMP)/ && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').zip $(GB800SE_PREFIX)*
	# cleanup
	rm -rf $(GB800SE_BUILD_TMP)
