#
# flashimage
#

### armbox vuuno4k

flashimage: $(D)/neutrino
	$(START_BUILD)
	$(MAKE) flash-image-vu-multi-rootfs
	$(TUXBOX_CUSTOMIZE)
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

ofgimage: $(D)/neutrino
	$(START_BUILD)
	$(MAKE) ITYPE=ofg flash-image-vu-rootfs
	$(TUXBOX_CUSTOMIZE)
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

online-image: $(D)/neutrino
	$(START_BUILD)
	$(MAKE) ITYPE=online flash-image-vu-online
	$(TUXBOX_CUSTOMIZE)
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

flash-clean:
	echo ""

#
FLASH_BUILD_TMP = $(BUILD_TMP)/image-build
VU_PREFIX       = vuplus/uno4k
VU_INITRD       = $(KERNEL_INITRD)
VU_FR           = echo This file forces the update. > $(FLASH_BUILD_TMP)/$(VU_PREFIX)/force.update

include make/common/vu-linux-image.mk
