#
# Simple DirectMedia Layer 1.2
#
LIBSDL_VER = 1.2.15
LIBSDL_SOURCE = SDL-$(LIBSDL_VER).tar.gz

$(ARCHIVE)/$(LIBSDL_SOURCE):
	$(DOWNLOAD) https://www.libsdl.org/release/$(LIBSDL_SOURCE)

$(D)/libsdl: $(D)/bootstrap $(ARCHIVE)/$(LIBSDL_SOURCE) $(KERNEL)
	$(START_BUILD)
	$(REMOVE)/SDL-$(LIBSDL_VER)
	$(UNTAR)/$(LIBSDL_SOURCE)
	$(CHDIR)/SDL-$(LIBSDL_VER); \
		$(call apply_patches, $(PKG_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--disable-static --enable-cdrom --enable-threads --enable-timers \
			--enable-file --disable-oss --disable-esd --disable-arts \
			--disable-diskaudio --disable-nas --disable-esd-shared --disable-esdtest \
			--disable-mintaudio --disable-nasm --disable-video-dga \
			--enable-video-fbcon \
			--disable-video-ps2gs --disable-video-ps3 \
			--disable-xbios --disable-gem --disable-video-dummy \
			--enable-input-events --enable-input-tslib --enable-pthreads \
			--enable-video-opengl \
			--disable-video-x11 \
			--disable-video-svga \
			--disable-video-picogui --disable-video-qtopia --enable-sdl-dlopen \
			--disable-rpath \
			--disable-pulseaudio \
		; \
		$(MAKE) ; \
		$(MAKE) install DESTDIR=$(TARGET_DIR) ; \
	$(REWRITE_LIBTOOL)
	$(REWRITE_PKGCONF)
	sed -i -e $(REWRITE_PKGCONF_RULES) $(TARGET_DIR)/usr/bin/sdl-config
	$(REMOVE)/SDL-$(LIBSDL_VER)
	$(TOUCH)
