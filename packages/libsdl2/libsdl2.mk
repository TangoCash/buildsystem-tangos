#
# Simple DirectMedia Layer 2.0
#
LIBSDL2_VER = 2.0.9
LIBSDL2_SOURCE = SDL2-$(LIBSDL2_VER).tar.gz

$(ARCHIVE)/$(LIBSDL2_SOURCE):
	$(DOWNLOAD) https://www.libsdl.org/release/$(LIBSDL2_SOURCE)

$(D)/libsdl2: $(D)/bootstrap $(ARCHIVE)/$(LIBSDL2_SOURCE) $(KERNEL)
	$(START_BUILD)
	$(REMOVE)/SDL2-$(LIBSDL2_VER)
	$(UNTAR)/$(LIBSDL2_SOURCE)
	$(CHDIR)/SDL2-$(LIBSDL2_VER); \
		$(call apply_patches, $(PKG_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--disable-oss \
			--disable-esd \
			--disable-arts \
			--disable-diskaudio \
			--disable-nas \
			--disable-esd-shared \
			--disable-esdtest \
			--disable-video-dummy \
			--enable-pthreads \
			--enable-sdl-dlopen \
			--disable-rpath \
			--disable-sndio \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) ; \
	$(REWRITE_LIBTOOL)
	$(REWRITE_PKGCONF)
	sed -i -e $(REWRITE_PKGCONF_RULES) $(TARGET_DIR)/usr/bin/sdl2-config
	$(REMOVE)/SDL2-$(LIBSDL2_VER)
	$(TOUCH)
