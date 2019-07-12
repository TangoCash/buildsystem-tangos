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
ifeq ($(BOXARCH), sh4)
	@for i in audio_7100 audio_7105 audio_7111 video_7100 video_7105 video_7109 video_7111; do \
		if [ ! -e $(SKEL_ROOT)/boot/$$i.elf ]; then \
			echo -e "\n    ERROR: One or more .elf files are missing in $(SKEL_ROOT)/boot!"; \
			echo "           $$i.elf is one of them"; \
			echo; \
			echo "    Correct this and retry."; \
			echo; \
		fi; \
	done
endif
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
ifeq ($(BOXARCH), sh4)
	mkdir -p $(STL_ARCHIVE)
endif
	mkdir -p $(BUILD_TMP)
	mkdir -p $(HOST_DIR)
	mkdir -p $(SOURCE_DIR)
	mkdir -p $(RELEASE_IMAGE_DIR)
	install -d $(CROSS_DIR)
	install -d $(HOST_DIR)/{bin,lib,share}
	install -d $(TARGET_DIR)/{bin,boot,etc,lib,sbin,usr,var}
	install -d $(TARGET_DIR)/etc/{init.d,mdev,network,rc.d}
	install -d $(TARGET_DIR)/etc/rc.d/{rc0.d,rc6.d}
	ln -sf ../init.d $(TARGET_DIR)/etc/rc.d/init.d
	install -d $(TARGET_DIR)/lib/{lsb,firmware}
	install -d $(TARGET_DIR)/usr/{bin,lib,sbin,share}
	install -d $(TARGET_DIR)/usr/lib/pkgconfig
	install -d $(TARGET_DIR)/usr/include/linux
	install -d $(TARGET_DIR)/usr/include/linux/dvb
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
ifeq ($(BOXARCH), arm)
BOOTSTRAP += $(D)/host_resize2fs
BOOTSTRAP += $(D)/cortex_strings
endif
ifeq ($(BOXARCH), sh4)
BOOTSTRAP += $(D)/host_module_init_tools
BOOTSTRAP += $(D)/host_mtd_utils
BOOTSTRAP += $(D)/host_mkcramfs
BOOTSTRAP += $(D)/host_mksquashfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd60 hd61))
BOOTSTRAP += $(D)/host_atools
endif

$(D)/bootstrap: $(BOOTSTRAP)
	@touch $@

#
# system-tools
#
SYSTEM_TOOLS  = $(D)/busybox
SYSTEM_TOOLS += $(D)/bash
ifeq ($(BOXARCH), arm)
SYSTEM_TOOLS += $(D)/libnsl
endif
SYSTEM_TOOLS += $(D)/zlib
SYSTEM_TOOLS += $(D)/sysvinit
SYSTEM_TOOLS += $(D)/diverse-tools
SYSTEM_TOOLS += $(D)/e2fsprogs
SYSTEM_TOOLS += $(D)/hdidle
SYSTEM_TOOLS += $(D)/portmap
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910 ufs922))
SYSTEM_TOOLS += $(D)/jfsutils
SYSTEM_TOOLS += $(D)/nfs_utils
endif
SYSTEM_TOOLS += $(D)/vsftpd
#SYSTEM_TOOLS += $(D)/autofs
SYSTEM_TOOLS += $(D)/udpxy
SYSTEM_TOOLS += $(D)/dvbsnoop
ifeq ($(BOXARCH), sh4)
SYSTEM_TOOLS += $(D)/fbshot
endif
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
SYSTEM_TOOLS += $(D)/ofgwrite
SYSTEM_TOOLS += $(D)/ethtool
endif
SYSTEM_TOOLS += $(D)/driver

$(D)/system-tools: $(SYSTEM_TOOLS) $(TOOLS)
	@touch $@

#
# preqs
#
#
$(DRIVER_DIR):
	$(call draw_line,)
	@echo '      Cloning $(GIT_NAME_DRIVER)-driver git repository'
	$(call draw_line,)
	if [ ! -e $(DRIVER_DIR)/.git ]; then \
		git clone $(GITHUB)/$(GIT_NAME_DRIVER)/driver.git driver; \
	fi

$(TOOLS_DIR):
	$(call draw_line,)
	@echo '      Cloning $(GIT_NAME_TOOLS)-tools git repository'
	$(call draw_line,)
	if [ ! -e $(TOOLS_DIR)/.git ]; then \
		git clone $(GITHUB)/$(GIT_NAME_TOOLS)/tools.git tools; \
	fi

$(FLASH_DIR):
	$(call draw_line,)
	@echo '      Cloning $(GIT_NAME_FLASH)-flash git repository'
	$(call draw_line,)
	if [ ! -e $(FLASH_DIR)/.git ]; then \
		git clone $(GITHUB)/$(GIT_NAME_FLASH)/flash.git flash; \
	fi
	@echo ''

PREQS  = $(TOOLS_DIR)

ifeq ($(BOXARCH), sh4)
PREQS += $(DRIVER_DIR)
PREQS += $(FLASH_DIR)
endif

preqs: $(PREQS)


