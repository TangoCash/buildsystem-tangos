#
# libnl
#
LIBNL_VER = 3.2.25
LIBNL_SOURCE = libnl-$(LIBNL_VER).tar.gz

$(ARCHIVE)/$(LIBNL_SOURCE):
	$(DOWNLOAD) https://www.infradead.org/~tgr/libnl/files/$(LIBNL_SOURCE)

$(D)/libnl: $(D)/bootstrap $(D)/openssl $(ARCHIVE)/$(LIBNL_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libnl-$(LIBNL_VER)
	$(UNTAR)/$(LIBNL_SOURCE)
	$(CHDIR)/libnl-$(LIBNL_VER); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--bindir=/.remove \
			--mandir=/.remove \
			--infodir=/.remove \
		make $(SILENT_OPT); \
		make install $(SILENT_OPT) DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/libnl-$(LIBNL_VER)
	$(TOUCH)
