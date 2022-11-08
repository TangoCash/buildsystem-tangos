#
# tools
#
tools-clean:
	rm -f $(D)/tools-*
	-$(MAKE) -C $(TOOLS_DIR)/aio-grab distclean
	-$(MAKE) -C $(TOOLS_DIR)/minimon distclean
	-$(MAKE) -C $(TOOLS_DIR)/msgbox distclean
	-$(MAKE) -C $(TOOLS_DIR)/satfind distclean
	-$(MAKE) -C $(TOOLS_DIR)/showiframe distclean
	-$(MAKE) -C $(TOOLS_DIR)/spf_tool distclean
	-$(MAKE) -C $(TOOLS_DIR)/tuxcom distclean
	-$(MAKE) -C $(TOOLS_DIR)/read-edid distclean
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), e4hdultra protek4k))
	-$(MAKE) -C $(TOOLS_DIR)/oled_ctrl distclean
	-$(MAKE) -C $(TOOLS_DIR)/initfb distclean
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuduo4kse vuuno4kse vuultimo4k vusolo4k))
	-$(MAKE) -C $(TOOLS_DIR)/oled_ctrl distclean
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo vuduo2 vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k))
	-$(MAKE) -C $(TOOLS_DIR)/initfb distclean
	-$(MAKE) -C $(TOOLS_DIR)/turnoff_power distclean
endif
ifneq ($(wildcard $(TOOLS_DIR)/own-tools),)
	-$(MAKE) -C $(TOOLS_DIR)/own-tools distclean
endif

#
# aio-grab
#
$(D)/tools-aio-grab: $(D)/bootstrap $(D)/libpng $(D)/libjpeg
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/aio-grab; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# initfb
#
$(D)/tools-initfb: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/initfb; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
			--with-boxmodel=$(BOXTYPE) \
			--with-boxtype=$(BOXTYPE) \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# minimon
#
$(D)/tools-minimon: $(D)/bootstrap $(D)/libjpeg_turbo2
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/minimon; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE) KERNEL_DIR=$(KERNEL_DIR) TARGET=$(TARGET) TARGET_DIR=$(TARGET_DIR); \
		$(MAKE) install KERNEL_DIR=$(KERNEL_DIR) TARGET=$(TARGET) TARGET_DIR=$(TARGET_DIR) DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# msgbox
#
$(D)/tools-msgbox: $(D)/bootstrap $(D)/libpng $(D)/freetype
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/msgbox; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
			--with-boxmodel=$(BOXTYPE) \
			--with-boxtype=$(BOXTYPE) \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# oled_ctrl
#
$(D)/tools-oled_ctrl: $(D)/bootstrap $(D)/freetype
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/oled_ctrl; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
			--with-boxmodel=$(BOXTYPE) \
			--with-boxtype=$(BOXTYPE) \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# read-edid
#
$(D)/tools-read-edid: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/read-edid; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# satfind
#
$(D)/tools-satfind: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/satfind; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# showiframe
#
$(D)/tools-showiframe: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/showiframe; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# spf_tool
#
$(D)/tools-spf_tool: $(D)/bootstrap $(D)/libusb
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/spf_tool; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# turnoff_power
#
$(D)/tools-turnoff_power: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/turnoff_power; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
			--with-boxmodel=$(BOXTYPE) \
			--with-boxtype=$(BOXTYPE) \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# tuxcom
#
$(D)/tools-tuxcom: $(D)/bootstrap $(D)/freetype
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/tuxcom; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
			--with-boxmodel=$(BOXTYPE) \
			--with-boxtype=$(BOXTYPE) \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# own-tools
#
$(D)/tools-own-tools: $(D)/bootstrap $(D)/libcurl
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/own-tools; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

TOOLS  = $(D)/tools-aio-grab
TOOLS += $(D)/tools-msgbox
TOOLS += $(D)/tools-satfind
TOOLS += $(D)/tools-showiframe
TOOLS += $(D)/tools-tuxcom
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), e4hdultra protek4k))
TOOLS += $(D)/tools-oled_ctrl
TOOLS += $(D)/tools-initfb
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuduo4kse vuuno4kse vuultimo4k vusolo4k))
TOOLS += $(D)/tools-oled_ctrl
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo vuduo2 vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k))
TOOLS += $(D)/tools-initfb
TOOLS += $(D)/tools-turnoff_power
endif
ifneq ($(wildcard $(TOOLS_DIR)/own-tools),)
TOOLS += $(D)/tools-own-tools
endif

$(D)/tools: $(TOOLS)
	@touch $@
