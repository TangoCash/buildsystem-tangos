#
# openssl2
#
OPENSSL2_MAJOR = 1.1.1
OPENSSL2_MINOR = h
OPENSSL2_VER = $(OPENSSL2_MAJOR)$(OPENSSL2_MINOR)
OPENSSL2_SOURCE = openssl-$(OPENSSL2_VER).tar.gz

OPENSSL2_SED_PATCH = sed -i 's|MAKEDEPPROG=makedepend|MAKEDEPPROG=$(CROSS_DIR)/bin/$$(CC) -M|' Makefile

$(ARCHIVE)/$(OPENSSL2_SOURCE):
	$(DOWNLOAD) https://www.openssl.org/source/$(OPENSSL2_SOURCE)

$(D)/openssl2: $(D)/bootstrap $(ARCHIVE)/$(OPENSSL2_SOURCE)
	$(START_BUILD)
	$(REMOVE)/openssl-$(OPENSSL2_VER)
	$(UNTAR)/$(OPENSSL2_SOURCE)
	$(CHDIR)/openssl-$(OPENSSL2_VER); \
		$(call apply_patches, $(PKG_PATCH)); \
		$(BUILDENV) \
		./Configure $(SILENT_OPT) \
			-DL_ENDIAN \
			shared \
			no-hw \
			linux-generic32 \
			--prefix=/usr \
			--openssldir=/etc/ssl \
		; \
		$(OPENSSL2_SED_PATCH); \
		$(MAKE) depend; \
		$(MAKE) all; \
		$(MAKE) install_sw DESTDIR=$(TARGET_DIR)
	chmod 0755 $(TARGET_LIB_DIR)/lib{crypto,ssl}.so.*
	$(REWRITE_PKGCONF)
	cd $(TARGET_DIR) && rm -rf etc/ssl/man usr/bin/openssl usr/lib/engines
	ln -sf libcrypto.so.1.1 $(TARGET_LIB_DIR)/libcrypto.so.0.9.8
	ln -sf libssl.so.1.1 $(TARGET_LIB_DIR)/libssl.so.0.9.8
	ln -sf libcrypto.so.1.1 $(TARGET_LIB_DIR)/libcrypto.so.1.0.0
	ln -sf libssl.so.1.1 $(TARGET_LIB_DIR)/libssl.so.1.0.0
	$(REMOVE)/openssl-$(OPENSSL2_VER)
	$(TOUCH)
