TOOLCHECK  = find-git find-svn find-gzip find-bzip2 find-patch find-gawk
TOOLCHECK += find-makeinfo find-automake find-gcc find-libtool
TOOLCHECK += find-yacc find-flex find-tic find-pkg-config find-help2man
TOOLCHECK += find-cmake find-gperf

find-%:
	@TOOL=$(patsubst find-%,%,$@); \
		type -p $$TOOL >/dev/null || \
		{ echo "required tool $$TOOL missing."; false; }

toolcheck: $(TOOLCHECK) preqs
	@echo "All required tools seem to be installed."
	@echo
	@if test "$(subst /bin/,,$(shell readlink /bin/sh))" != bash; then \
		echo "WARNING: /bin/sh is not linked to bash."; \
		echo "         This configuration might work, but is not supported."; \
		echo; \
	fi

#
# directories
#
$(D)/directories:
	$(START_BUILD)
	mkdir -p $(D)
	mkdir -p $(ARCHIVE)
	mkdir -p $(BUILD_TMP)
	mkdir -p $(HOST_DIR)
	mkdir -p $(SOURCE_DIR)
	mkdir -p $(RELEASE_IMAGE_DIR)
	install -d $(HOST_DIR)/{bin,lib,share}
	install -d $(TARGET_DIR)/{bin,boot,etc,lib,sbin,usr,var}
	install -d $(TARGET_DIR)/etc/{init.d,mdev,network,rc.d}
	install -d $(TARGET_DIR)/etc/rc.d/{rc0.d,rc6.d}
	ln -sf ../init.d $(TARGET_DIR)/etc/rc.d/init.d
	install -d $(TARGET_DIR)/lib/{lsb,firmware}
	install -d $(TARGET_DIR)/usr/{bin,lib,sbin,share}
	if [ $(BOXARCH) = "aarch64" ]; then \
		cd ${TARGET_DIR}; ln -sf lib lib64; \
		cd ${TARGET_DIR}/usr; ln -sf lib lib64; \
	fi
	install -d $(TARGET_LIB_DIR)/pkgconfig
	install -d $(TARGET_INCLUDE_DIR)/linux
	install -d $(TARGET_INCLUDE_DIR)/linux/dvb
	install -d $(TARGET_DIR)/var/{etc,lib,run}
	install -d $(TARGET_DIR)/var/lib/{opkg,misc,nfs}
	install -d $(TARGET_DIR)/var/bin
	$(TOUCH)

#
# bootstrap
#
BOOTSTRAP  = $(D)/directories
BOOTSTRAP += $(D)/host_ccache
BOOTSTRAP += $(CROSSTOOL)
BOOTSTRAP += $(TARGET_DIR)/lib/libc.so.6
BOOTSTRAP += $(D)/host_pkgconfig
BOOTSTRAP += $(D)/host_resize2fs
BOOTSTRAP += $(D)/host_parted
BOOTSTRAP += $(D)/host_qrencode

$(D)/bootstrap: $(BOOTSTRAP)
	@touch $@

#
# system-tools
#
SYSTEM_TOOLS  = $(D)/libnsl
SYSTEM_TOOLS += $(D)/bash
SYSTEM_TOOLS += $(D)/wget
SYSTEM_TOOLS += $(D)/busybox
SYSTEM_TOOLS += $(D)/zlib
SYSTEM_TOOLS += $(D)/sysvinit
SYSTEM_TOOLS += $(D)/build-root-etc
SYSTEM_TOOLS += $(D)/e2fsprogs
SYSTEM_TOOLS += $(D)/f2fs-tools
SYSTEM_TOOLS += $(D)/jfsutils
SYSTEM_TOOLS += $(D)/nfs_utils
SYSTEM_TOOLS += $(D)/hdidle
ifeq ($(NEED_TIRPC), 1)
SYSTEM_TOOLS += $(D)/rpcbind
else
SYSTEM_TOOLS += $(D)/portmap
endif
SYSTEM_TOOLS += $(D)/vsftpd
#SYSTEM_TOOLS += $(D)/autofs
#SYSTEM_TOOLS += $(D)/udpxy
SYSTEM_TOOLS += $(D)/dvbsnoop
SYSTEM_TOOLS += $(D)/ofgwrite
SYSTEM_TOOLS += $(D)/ethtool
SYSTEM_TOOLS += $(D)/driver

$(D)/system-tools: $(SYSTEM_TOOLS) $(TOOLS)
	@touch $@

#
# preqs
#
#
preqs:
	@mkdir -p $(OWN_BUILD)/neutrino-hd
	@mkdir -p $(OWN_BUILD)/neutrino-hd.$(BOXTYPE)


