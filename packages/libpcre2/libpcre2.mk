#
# libpcre2
#
LIBPCRE2_VER = 10.33
LIBPCRE2_SOURCE = pcre2-$(LIBPCRE2_VER).tar.bz2

$(ARCHIVE)/$(LIBPCRE2_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/pcre/files/pcre2/$(LIBPCRE2_VER)/$(LIBPCRE2_SOURCE)

$(D)/libpcre2: $(D)/bootstrap $(ARCHIVE)/$(LIBPCRE2_SOURCE)
	$(START_BUILD)
	$(REMOVE)/pcre2-$(LIBPCRE2_VER)
	$(UNTAR)/$(LIBPCRE2_SOURCE)
	$(CHDIR)/pcre2-$(LIBPCRE2_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--enable-utf8 \
			--enable-unicode-properties \
			--enable-pcre2-16 \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_DIR)/usr/bin/pcre2-config $(HOST_DIR)/bin/pcre2-config
	sed -i -e $(REWRITE_PKGCONF_RULES) $(HOST_DIR)/bin/pcre2-config
	$(REWRITE_LIBTOOL)
	$(REWRITE_PKGCONF)
	$(REMOVE)/pcre2-$(LIBPCRE2_VER)
	$(TOUCH)
