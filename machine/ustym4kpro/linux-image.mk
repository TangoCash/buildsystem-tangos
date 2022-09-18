#
# flashimage
#

### armbox ustym4kpro

flashimage: $(D)/neutrino
	$(START_BUILD)
	$(MAKE) flash-image-ustym4kpro-multi-disk flash-image-ustym4kpro-multi-rootfs
	$(TUXBOX_CUSTOMIZE)
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

ofgimage: $(D)/neutrino
	$(START_BUILD)
	$(MAKE) ITYPE=ofg flash-image-ustym4kpro-multi-rootfs
	$(TUXBOX_CUSTOMIZE)
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

online-image: $(D)/neutrino
	$(START_BUILD)
	$(MAKE) ITYPE=online flash-image-ustym4kpro-online
	$(TUXBOX_CUSTOMIZE)
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

flash-clean:
	echo ""

#
FLASH_BUILD_TMP = $(BUILD_TMP)/image-build
include machine/common/octagon-linux-image.mk
