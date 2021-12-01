#
# netsurf
#
NETSURF_VERSION = 3.10
NETSURF_DIR     = netsurf-all-$(NETSURF_VERSION)
NETSURF_SOURCE  = netsurf-all-$(NETSURF_VERSION).tar.gz
NETSURF_SITE    = http://download.netsurf-browser.org/netsurf/releases/source-full
NETSURF_PATCH   = $(PATCHES)/netsurf

NETSURF_CONF_OPTS = \
	PREFIX=/usr \
	TMP_PREFIX=$(BUILD_TMP)/netsurf-all-$(NETSURF_VERSION)/tmpusr \
	NETSURF_USE_DUKTAPE=YES \
	NETSURF_USE_LIBICONV_PLUG=YES \
	NETSURF_FB_FONTLIB=freetype \
	NETSURF_FB_FRONTEND=linux \
	NETSURF_FB_RESPATH=/usr/share/netsurf/ \
	NETSURF_FRAMEBUFFER_RESOURCES=/usr/share/netsurf/ \
	NETSURF_FB_FONTPATH=/usr/share/fonts \
	NETSURF_FB_FONT_SANS_SERIF=neutrino.ttf \
	TARGET=framebuffer

$(ARCHIVE)/$(NETSURF_SOURCE):
	$(DOWNLOAD) $(NETSURF_SITE)/$(NETSURF_SOURCE)

$(D)/netsurf: $(D)/bootstrap $(D)/libpng $(D)/libjpeg $(D)/openssl $(D)/freetype $(D)/expat $(D)/libcurl $(ARCHIVE)/$(NETSURF_SOURCE)
	$(START_BUILD)
	$(REMOVE)/$(NETSURF_DIR)
	$(UNTAR)/$(NETSURF_SOURCE)
	$(CHDIR)/$(NETSURF_DIR); \
		$(call apply_patches, $(NETSURF_PATCH)); \
		$(BUILDENV) \
		XCFLAGS="-Isrc -I$(BUILD_DIR)/netsurf-all-$(NETSURF_VERSION)/tmpusr/include" \
		XLDFLAGS="-L$(BUILD_DIR)/netsurf-all-$(NETSURF_VERSION)/tmpusr/lib" \
		CFLAGS="$(TARGET_CFLAGS) -I$(BUILD_DIR)/netsurf-all-$(NETSURF_VERSION)/tmpusr/include" \
		LDFLAGS="$(TARGET_LDFLAGS) -L$(BUILD_DIR)/netsurf-all-$(NETSURF_VERSION)/tmpusr/lib" \
		$(MAKE) $(NETSURF_CONF_OPTS); \
		$(MAKE) $(NETSURF_CONF_OPTS) install DESTDIR=$(TARGET_DIR)
	mkdir -p $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins
	mv $(TARGET_DIR)/usr/bin/netsurf-fb $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/netsurf-fb.so
	echo "name=Netsurf Web Browser"	 > $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/netsurf-fb.cfg
	echo "desc=Web Browser"		>> $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/netsurf-fb.cfg
	echo "type=2"			>> $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/netsurf-fb.cfg
	$(REMOVE)/$(NETSURF_DIR)
	$(TOUCH)
