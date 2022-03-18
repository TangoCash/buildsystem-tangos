#
# rpcbind
#
RPCBIND_VER = 1.2.6
RPCBIND_DIR = rpcbind-$(RPCBIND_VER)
RPCBIND_SOURCE = rpcbind-$(RPCBIND_VER).tar.bz2
RPCBIND_SITE = https://sourceforge.net/projects/rpcbind/files/rpcbind/$(RPCBIND_VER)

$(ARCHIVE)/$(RPCBIND_SOURCE):
	$(DOWNLOAD) $(RPCBIND_SITE)/$(RPCBIND_SOURCE)

$(D)/rpcbind: $(D)/bootstrap $(D)/libtirpc $(ARCHIVE)/$(RPCBIND_SOURCE)
	$(START_BUILD)
	$(REMOVE)/$(RPCBIND_DIR)
	$(UNTAR)/$(RPCBIND_SOURCE)
	$(CHDIR)/$(RPCBIND_DIR); \
		$(call apply_patches, $(PKG_PATCH)); \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--with-rpcuser=root \
			--with-systemdsystemunitdir=no \
			--enable-rmtcalls \
			--enable-warmstarts \
			--with-rpcuser=nobody \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(RPCBIND_DIR)
	$(TOUCH)
