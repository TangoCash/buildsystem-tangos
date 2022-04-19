#
# The Cairo library GObject wrapper library
#
CAIRO_VER = 1.16.0
CAIRO_SOURCE = cairo-$(CAIRO_VER).tar.xz

CAIRO_OPTS ?= \
		--disable-egl \
		--disable-glesv2

$(ARCHIVE)/$(CAIRO_SOURCE):
	$(DOWNLOAD) https://www.cairographics.org/releases/$(CAIRO_SOURCE)

$(D)/cairo: $(ARCHIVE)/$(CAIRO_SOURCE) $(D)/bootstrap $(D)/libglib2 $(D)/libpng $(D)/pixman $(D)/zlib
	$(START_BUILD)
	$(REMOVE)/cairo-$(CAIRO_VER)
	$(UNTAR)/$(CAIRO_SOURCE)
	$(CHDIR)/cairo-$(CAIRO_VER); \
		$(call apply_patches, $(PKG_PATCH)); \
		$(BUILDENV) \
		ax_cv_c_float_words_bigendian="no" \
		./configure $(SILENT_OPT) $(CONFIGURE_OPTS) \
			--prefix=/usr \
			--with-x=no \
			--disable-xlib \
			--disable-xcb \
			$(CAIRO_OPTS) \
			--disable-gl \
			--enable-tee \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_DIR)/usr/bin/cairo-sphinx
	rm -rf $(TARGET_LIB_DIR)/cairo/cairo-fdr*
	rm -rf $(TARGET_LIB_DIR)/cairo/cairo-sphinx*
	rm -rf $(TARGET_LIB_DIR)/cairo/.debug/cairo-fdr*
	rm -rf $(TARGET_LIB_DIR)/cairo/.debug/cairo-sphinx*
	$(REWRITE_LIBTOOL)
	$(REWRITE_PKGCONF)
	$(REMOVE)/cairo-$(CAIRO_VER)
	$(TOUCH)
