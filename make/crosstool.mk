# makefile to build crosstools

$(TARGET_DIR)/lib/libc.so.6:
	if test -e $(CROSS_DIR)/$(TARGET)/sys-root/lib; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/lib/*so* $(TARGET_DIR)/lib; \
	else \
		cp -a $(CROSS_DIR)/$(TARGET)/lib/*so* $(TARGET_DIR)/lib; \
	fi

#
# crosstool-ng
#
CROSSTOOL_NG_VER     = 5a09578
CROSSTOOL_NG_DIR     = crosstool-ng.git
CROSSTOOL_NG_SOURCE  = $(CROSSTOOL_NG_DIR)
CROSSTOOL_NG_URL     = $(GITHUB)/crosstool-ng/crosstool-ng
CROSSTOOL_NG_CONFIG  = crosstool-ng-$(BOXARCH)-$(CROSSTOOL_GCC_VER)
CROSSTOOL_NG_BACKUP  = $(ARCHIVE)/$(CROSSTOOL_NG_CONFIG)-kernel-$(KERNEL_VER)-backup.tar.gz
#CROSSTOOL_NG_PATCH   = crosstool-revert-autoconf-2.71.patch

# -----------------------------------------------------------------------------

ifeq ($(wildcard $(CROSS_DIR)/build.log.bz2),)
CROSSTOOL = crosstool
crosstool:
	make MAKEFLAGS=--no-print-directory crosstool-ng
	if [ ! -e $(CROSSTOOL_NG_BACKUP) ]; then \
		make crosstool-backup; \
	fi;

crosstool-ng: $(D)/directories $(D)/kernel.do_prepare $(ARCHIVE)/$(KERNEL_SRC)
	$(START_BUILD)
	$(REMOVE)/$(CROSSTOOL_NG_DIR)
	$(HELPERS_DIR)/get-git-source.sh $(CROSSTOOL_NG_URL) $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	cp -a -t $(BUILD_TMP) $(ARCHIVE)/$(CROSSTOOL_NG_DIR)
	unset CONFIG_SITE LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE LD_LIBRARY_PATH; \
	ulimit -n 2048; \
	$(CHDIR)/$(CROSSTOOL_NG_DIR); \
		git checkout -q $(CROSSTOOL_NG_VER); \
		$(call apply_patches, $(CROSSTOOL_NG_PATCH)); \
		install -m 644 $(PATCHES)/ct-ng/$(CROSSTOOL_NG_CONFIG).config .config; \
		sed -i "s|^CT_PARALLEL_JOBS=.*|CT_PARALLEL_JOBS=$(PARALLEL_JOBS)|" .config; \
		\
		export CT_NG_ARCHIVE=$(ARCHIVE); \
		export CT_NG_BASE_DIR=$(CROSS_DIR); \
		export CT_NG_CUSTOM_KERNEL=$(KERNEL_DIR); \
		test -f ./configure || ./bootstrap; \
		./configure --enable-local $(SILENT_OPT); \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
	test -e $(CROSS_DIR)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_DIR)/$(TARGET)/
	rm -f $(CROSS_DIR)/$(TARGET)/sys-root/lib/libstdc++.so.6.0.*-gdb.py
	$(REMOVE)/$(CROSSTOOL_NG_DIR)
endif

# -----------------------------------------------------------------------------

crosstool-config:
	make MAKEFLAGS=--no-print-directory crosstool-ng-config

crosstool-ng-config: directories
	$(REMOVE)/$(CROSSTOOL_NG_DIR)
	$(HELPERS_DIR)/get-git-source.sh $(CROSSTOOL_NG_URL) $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	cp -a -t $(BUILD_TMP) $(ARCHIVE)/$(CROSSTOOL_NG_DIR)
	unset CONFIG_SITE; \
	$(CHDIR)/$(CROSSTOOL_NG_DIR); \
		git checkout -q $(CROSSTOOL_NG_VER); \
		install -m 644 $(PATCHES)/ct-ng/$(CROSSTOOL_NG_CONFIG).config .config; \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		./ct-ng menuconfig

# -----------------------------------------------------------------------------

crosstool-upgradeconfig:
	make MAKEFLAGS=--no-print-directory crosstool-ng-upgradeconfig

crosstool-ng-upgradeconfig: directories
	$(REMOVE)/$(CROSSTOOL_NG_DIR)
	$(HELPERS_DIR)/get-git-source.sh $(CROSSTOOL_NG_URL) $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	cp -a -t $(BUILD_TMP) $(ARCHIVE)/$(CROSSTOOL_NG_DIR)
	unset CONFIG_SITE; \
	$(CHDIR)/$(CROSSTOOL_NG_DIR); \
		git checkout -q $(CROSSTOOL_NG_VER); \
		install -m 644 $(PATCHES)/ct-ng/$(CROSSTOOL_NG_CONFIG).config .config; \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		./ct-ng upgradeconfig

# -----------------------------------------------------------------------------

crosstool-backup:
	if [ -e $(CROSSTOOL_NG_BACKUP) ]; then \
		mv $(CROSSTOOL_NG_BACKUP) $(CROSSTOOL_NG_BACKUP).old; \
	fi; \
	cd $(CROSS_DIR); \
	tar czvf $(CROSSTOOL_NG_BACKUP) *

crosstool-restore: $(CROSSTOOL_NG_BACKUP)
	rm -rf $(CROSS_DIR) ; \
	if [ ! -e $(CROSS_DIR) ]; then \
		mkdir -p $(CROSS_DIR); \
	fi;
	tar xzvf $(CROSSTOOL_NG_BACKUP) -C $(CROSS_DIR)

crosstool-renew:
	ccache -cCz
	make distclean
	rm -rf $(CROSS_DIR)
	make crosstool
