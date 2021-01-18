#
# tvheadend
#

TVHEADEND_DEPS  = $(D)/bootstrap $(D)/openssl $(D)/zlib
TVHEADEND_DEPS += $(LOCAL_TVHEADEND_DEPS)

TVHEADEND_CONFIG_OPTS +=$(LOCAL_TVHEADEND_BUILD_OPTIONS)

TVHEADEND_PATCHES  = tvheadend-git-$(TVHEADEND_VER).patch
TVHEADEND_PATCHES += tvheadend-adjust-for-64bit-time_t.patch

TVHEADEND_VER = 22eeadd
TVHEADEND_SOURCE = tvheadend-git-$(TVHEADEND_VER).tar.bz2
TVHEADEND_URL = https://github.com/tvheadend/tvheadend.git

$(ARCHIVE)/$(TVHEADEND_SOURCE):
	$(HELPERS_DIR)/get-git-archive.sh $(TVHEADEND_URL) $(TVHEADEND_VER) $(notdir $@) $(ARCHIVE)

$(D)/tvheadend.do_prepare: $(ARCHIVE)/$(TVHEADEND_SOURCE) $(TVHEADEND_DEPS)
	$(START_BUILD)
	$(REMOVE)/tvheadend-git-$(TVHEADEND_VER)
	$(UNTAR)/$(TVHEADEND_SOURCE)
	$(CHDIR)/tvheadend-git-$(TVHEADEND_VER); \
		$(call apply_patches, $(TVHEADEND_PATCHES))
	@touch $@

$(SOURCE_DIR)/tvheadend/config.status: $(D)/tvheadend.do_prepare
	$(CHDIR)/tvheadend-git-$(TVHEADEND_VER); \
		$(BUILDENV) \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--disable-hdhomerun_static \
			--disable-avahi \
			--disable-tvhcsa \
			--disable-libav \
			--disable-ffmpeg_static \
			--disable-libx264 \
			--disable-libx264-static \
			--disable-libx265 \
			--disable-libx265-static \
			--disable-libx264 \
			--disable-libx264-static \
			--disable-libvpx \
			--disable-libvpx-static \
			--disable-libtheora \
			--disable-libtheora-static \
			--disable-libvorbis \
			--disable-libvorbis-static \
			--disable-libfdkaac \
			--disable-libfdkaac-static \
			--disable-uriparser \
			--disable-pcre \
			--disable-pcre2 \
			--disable-dvben50221 \
			--disable-dbus_1 \
			--disable-timeshift \
			--disable-libopus \
			--disable-libopus_static \
			--enable-pngquant \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

$(D)/tvheadend.do_compile: $(SOURCE_DIR)/tvheadend/config.status
	$(CHDIR)/tvheadend-git-$(TVHEADEND_VER); \
		$(MAKE) all
	@touch $@

$(D)/tvheadend: $(D)/tvheadend.do_prepare $(D)/tvheadend.do_compile
	$(CHDIR)/tvheadend-git-$(TVHEADEND_VER); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)
