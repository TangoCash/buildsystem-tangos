#
# vsftpd
#
VSFTPD_VER = 3.0.5
VSFTPD_SOURCE = vsftpd-$(VSFTPD_VER).tar.gz

$(ARCHIVE)/$(VSFTPD_SOURCE):
	$(DOWNLOAD) https://security.appspot.com/downloads/$(VSFTPD_SOURCE)

$(D)/vsftpd: $(D)/bootstrap $(D)/openssl $(ARCHIVE)/$(VSFTPD_SOURCE)
	$(START_BUILD)
	$(REMOVE)/vsftpd-$(VSFTPD_VER)
	$(UNTAR)/$(VSFTPD_SOURCE)
	$(CHDIR)/vsftpd-$(VSFTPD_VER); \
		$(call apply_patches, $(PKG_PATCH)); \
		$(MAKE) clean; \
		$(MAKE) $(BUILDENV); \
		$(MAKE) install PREFIX=$(TARGET_DIR)
	install -m 755 $(PKG_FILES)/etc/init.d/vsftpd $(TARGET_DIR)/etc/init.d/
	install -m 644 $(PKG_FILES)/etc/vsftpd.conf $(TARGET_DIR)/etc/
	cd $(TARGET_DIR)/usr/sbin && ln -sf /usr/bin/vsftpd vsftpd
	$(REMOVE)/vsftpd-$(VSFTPD_VER)
	$(TOUCH)
