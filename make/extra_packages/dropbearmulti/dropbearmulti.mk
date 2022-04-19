#
# dropbearmulti
#
DROPBEARMULTI_VER = b8669b0
#DROPBEARMULTI_VER = 846d38f
DROPBEARMULTI_SOURCE = dropbearmulti-git-$(DROPBEARMULTI_VER).tar.bz2
DROPBEARMULTI_URL = $(GITHUB)/mkj/dropbear.git

$(ARCHIVE)/$(DROPBEARMULTI_SOURCE):
	$(HELPERS_DIR)/get-git-archive.sh $(DROPBEARMULTI_URL) $(DROPBEARMULTI_VER) $(notdir $@) $(ARCHIVE)

$(D)/dropbearmulti: $(D)/bootstrap $(ARCHIVE)/$(DROPBEARMULTI_SOURCE)
	$(START_BUILD)
	$(REMOVE)/dropbearmulti-git-$(DROPBEARMULTI_VER)
	$(UNTAR)/$(DROPBEARMULTI_SOURCE)
	$(CHDIR)/dropbearmulti-git-$(DROPBEARMULTI_VER); \
		$(BUILDENV) \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-syslog \
			--disable-lastlog \
			--infodir=/.remove \
			--localedir=/.remove/locale \
			--mandir=/.remove \
			--docdir=/.remove \
			--htmldir=/.remove \
			--dvidir=/.remove \
			--pdfdir=/.remove \
			--psdir=/.remove \
			--disable-shadow \
			--disable-zlib \
			--disable-utmp \
			--disable-utmpx \
			--disable-wtmp \
			--disable-wtmpx \
			--disable-loginfunc \
			--disable-pututline \
			--disable-pututxline \
		; \
		$(MAKE) PROGRAMS="dropbear scp dropbearkey" MULTI=1; \
		$(MAKE) PROGRAMS="dropbear scp dropbearkey" MULTI=1 install DESTDIR=$(TARGET_DIR)
	cd $(TARGET_DIR)/usr/bin && ln -sf /usr/bin/dropbearmulti dropbear
	install -m 755 $(PKG_FILES)/dropbear $(TARGET_DIR)/etc/init.d/
	install -d -m 0755 $(TARGET_DIR)/etc/dropbear
	$(REMOVE)/dropbearmulti-git-$(DROPBEARMULTI_VER)
	$(TOUCH)
