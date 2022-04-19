#
# Pixman: Pixel Manipulation library
#
PIXMAN_VER = 0.34.0
PIXMAN_SOURCE = pixman-$(PIXMAN_VER).tar.gz

$(ARCHIVE)/$(PIXMAN_SOURCE):
	$(DOWNLOAD) https://www.cairographics.org/releases/$(PIXMAN_SOURCE)

$(D)/pixman: $(ARCHIVE)/$(PIXMAN_SOURCE) $(D)/bootstrap $(D)/zlib $(D)/libpng
	$(START_BUILD)
	$(REMOVE)/pixman-$(PIXMAN_VER)
	$(UNTAR)/$(PIXMAN_SOURCE)
	$(CHDIR)/pixman-$(PIXMAN_VER); \
		$(call apply_patches, $(PKG_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-gtk \
			--disable-arm-simd \
			--disable-loongson-mmi \
			--disable-docs \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REWRITE_PKGCONF)
	$(REMOVE)/pixman-$(PIXMAN_VER)
	$(TOUCH)
