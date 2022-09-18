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
			--enable-silent-rules \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		install -m 644 $(PKG_FILES)/rpc $(TARGET_DIR)/etc/rpc
		install -m 644 $(PKG_FILES)/rpcbind.conf $(TARGET_DIR)/etc/rpcbind.conf
		install -m 644 $(PKG_FILES)/netconfig $(TARGET_DIR)/etc/netconfig
		install -m 755 $(PKG_FILES)/rpcbind.init $(TARGET_DIR)/etc/init.d/rpcbind
		install -m 755 $(PKG_FILES)/rpcbind.init $(TARGET_DIR)/etc/init.d/portmap
	$(REMOVE)/$(RPCBIND_DIR)
	$(TOUCH)
