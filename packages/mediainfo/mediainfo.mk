#
# mediainfo
#
MEDIAINFO_VER = 23.04
MEDIAINFO_SOURCE = mediainfo_$(MEDIAINFO_VER).tar.bz2

$(ARCHIVE)/$(MEDIAINFO_SOURCE):
	$(DOWNLOAD) https://mediaarea.net/download/source/mediainfo/$(MEDIAINFO_VER)/$(MEDIAINFO_SOURCE)

$(D)/mediainfo: bootstrap $(D)/zlib $(D)/libzen $(D)/libmediainfo $(ARCHIVE)/$(MEDIAINFO_SOURCE)
	$(START_BUILD)
	$(REMOVE)/MediaInfo
	$(UNTAR)/$(MEDIAINFO_SOURCE)
	$(CHDIR)/MediaInfo/Project/GNU/CLI; \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/MediaInfo
	$(TOUCH)
