#
# libmediainfo
#
LIBMEDIAINFO_VER = 21.09
LIBMEDIAINFO_SOURCE = libmediainfo_$(LIBMEDIAINFO_VER).tar.bz2

$(ARCHIVE)/$(LIBMEDIAINFO_SOURCE):
	$(DOWNLOAD) https://mediaarea.net/download/source/libmediainfo/$(LIBMEDIAINFO_VER)/$(LIBMEDIAINFO_SOURCE)

$(D)/libmediainfo: bootstrap $(D)/zlib $(D)/libzen $(ARCHIVE)/$(LIBMEDIAINFO_SOURCE)
	$(START_BUILD)
	$(REMOVE)/MediaInfoLib
	$(UNTAR)/$(LIBMEDIAINFO_SOURCE)
	$(CHDIR)/MediaInfoLib/Project/GNU/Library; \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/MediaInfoLib
	$(TOUCH)

