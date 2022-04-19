#
# HarfBuzz is an OpenType text shaping engine
#
HARFBUZZ_VER = 1.8.8
HARFBUZZ_SOURCE = harfbuzz-$(HARFBUZZ_VER).tar.bz2

$(ARCHIVE)/$(HARFBUZZ_SOURCE):
	$(DOWNLOAD) https://www.freedesktop.org/software/harfbuzz/release/$(HARFBUZZ_SOURCE)

$(D)/harfbuzz: $(ARCHIVE)/$(HARFBUZZ_SOURCE) $(D)/bootstrap $(D)/libglib2 $(D)/cairo $(D)/freetype
	$(START_BUILD)
	$(REMOVE)/harfbuzz-$(HARFBUZZ_VER)
	$(UNTAR)/$(HARFBUZZ_SOURCE)
	$(CHDIR)/harfbuzz-$(HARFBUZZ_VER); \
		$(call apply_patches, $(PKG_PATCH)); \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-cairo \
			--with-freetype \
			--without-fontconfig \
			--with-glib \
			--without-graphite2 \
			--without-icu \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REWRITE_PKGCONF)
	$(REMOVE)/harfbuzz-$(HARFBUZZ_VER)
	$(TOUCH)
