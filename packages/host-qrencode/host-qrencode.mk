#
# qrencode
#
HOST_QRENCODE_VER = 4.1.1
HOST_QRENCODE_SOURCE = qrencode-$(HOST_QRENCODE_VER).tar.gz

$(ARCHIVE)/$(HOST_QRENCODE_SOURCE):
	$(DOWNLOAD) https://fukuchi.org/works/qrencode/$(HOST_QRENCODE_SOURCE)

$(D)/host_qrencode: $(D)/directories $(ARCHIVE)/$(HOST_QRENCODE_SOURCE)
	$(START_BUILD)
	$(UNTAR)/$(HOST_QRENCODE_SOURCE)
	$(CHDIR)/qrencode-$(HOST_QRENCODE_VER); \
		export PKG_CONFIG=/usr/bin/pkg-config; \
		export PKG_CONFIG_PATH=$(HOST_DIR)/lib/pkgconfig; \
		./configure $(SILENT_OPT) \
			--prefix=$(HOST_DIR) \
			--sbindir=$(HOST_DIR)/bin \
		; \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/qrencode-$(HOST_QRENCODE_VER)
	$(TOUCH)
