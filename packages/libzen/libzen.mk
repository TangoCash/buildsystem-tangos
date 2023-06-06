#
# libzen
#
LIBZEN_VER = 0.4.41
LIBZEN_SOURCE = libzen_$(LIBZEN_VER).tar.bz2

$(ARCHIVE)/$(LIBZEN_SOURCE):
	$(DOWNLOAD) https://mediaarea.net/download/source/libzen/$(LIBZEN_VER)/$(LIBZEN_SOURCE)

$(D)/libzen: bootstrap $(D)/zlib $(ARCHIVE)/$(LIBZEN_SOURCE)
	$(START_BUILD)
	$(REMOVE)/ZenLib
	$(UNTAR)/$(LIBZEN_SOURCE)
	$(CHDIR)/ZenLib/Project/GNU/Library; \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/ZenLib
	$(TOUCH)
