#
# host_pkgconfig
#
HOST_PKGCONFIG_VER = 0.29.2
HOST_PKGCONFIG_SOURCE = pkg-config-$(HOST_PKGCONFIG_VER).tar.gz

$(ARCHIVE)/$(HOST_PKGCONFIG_SOURCE):
	$(DOWNLOAD) https://pkgconfig.freedesktop.org/releases/$(HOST_PKGCONFIG_SOURCE)

$(D)/host_pkgconfig: $(D)/directories $(ARCHIVE)/$(HOST_PKGCONFIG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/pkg-config-$(HOST_PKGCONFIG_VER)
	$(UNTAR)/$(HOST_PKGCONFIG_SOURCE)
	$(CHDIR)/pkg-config-$(HOST_PKGCONFIG_VER); \
		./configure $(SILENT_OPT) \
			--prefix=$(HOST_DIR) \
			--program-prefix=$(TARGET)- \
			--disable-host-tool \
			--with-pc_path=$(PKG_CONFIG_PATH) \
		; \
		$(MAKE); \
		$(MAKE) install
	ln -sf $(TARGET)-pkg-config $(HOST_DIR)/bin/pkg-config
	$(REMOVE)/pkg-config-$(HOST_PKGCONFIG_VER)
	$(TOUCH)

#
# host_module_init_tools
#
HOST_MODULE_INIT_TOOLS_VER = $(MODULE_INIT_TOOLS_VER)
HOST_MODULE_INIT_TOOLS_SOURCE = $(MODULE_INIT_TOOLS_SOURCE)
HOST_MODULE_INIT_TOOLS_PATCH = module-init-tools-$(HOST_MODULE_INIT_TOOLS_VER).patch

$(D)/host_module_init_tools: $(D)/directories $(ARCHIVE)/$(HOST_MODULE_INIT_TOOLS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/module-init-tools-$(HOST_MODULE_INIT_TOOLS_VER)
	$(UNTAR)/$(HOST_MODULE_INIT_TOOLS_SOURCE)
	$(CHDIR)/module-init-tools-$(HOST_MODULE_INIT_TOOLS_VER); \
		$(call apply_patches, $(HOST_MODULE_INIT_TOOLS_PATCH)); \
		autoreconf -fi $(SILENT_OPT); \
		./configure $(SILENT_OPT) \
			--prefix=$(HOST_DIR) \
			--sbindir=$(HOST_DIR)/bin \
		; \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/module-init-tools-$(HOST_MODULE_INIT_TOOLS_VER)
	$(TOUCH)

#
# host_mtd_utils
#
HOST_MTD_UTILS_VER = $(MTD_UTILS_VER)
HOST_MTD_UTILS_SOURCE = $(MTD_UTILS_SOURCE)
HOST_MTD_UTILS_PATCH = host-mtd-utils-$(HOST_MTD_UTILS_VER).patch
HOST_MTD_UTILS_PATCH += host-mtd-utils-$(HOST_MTD_UTILS_VER)-sysmacros.patch

$(D)/host_mtd_utils: $(D)/directories $(ARCHIVE)/$(HOST_MTD_UTILS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/mtd-utils-$(HOST_MTD_UTILS_VER)
	$(UNTAR)/$(HOST_MTD_UTILS_SOURCE)
	$(CHDIR)/mtd-utils-$(HOST_MTD_UTILS_VER); \
		$(call apply_patches, $(HOST_MTD_UTILS_PATCH)); \
		$(MAKE) `pwd`/mkfs.jffs2 `pwd`/sumtool BUILDDIR=`pwd` WITHOUT_XATTR=1 DESTDIR=$(HOST_DIR); \
		$(MAKE) install DESTDIR=$(HOST_DIR)/bin
	$(REMOVE)/mtd-utils-$(HOST_MTD_UTILS_VER)
	$(TOUCH)

#
# host_mkcramfs
#
HOST_MKCRAMFS_VER = 1.1
HOST_MKCRAMFS_SOURCE = cramfs-$(HOST_MKCRAMFS_VER).tar.gz

$(ARCHIVE)/$(HOST_MKCRAMFS_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/cramfs/files/cramfs/$(HOST_MKCRAMFS_VER)/$(HOST_MKCRAMFS_SOURCE)

$(D)/host_mkcramfs: $(D)/directories $(ARCHIVE)/$(HOST_MKCRAMFS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/cramfs-$(HOST_MKCRAMFS_VER)
	$(UNTAR)/$(HOST_MKCRAMFS_SOURCE)
	$(CHDIR)/cramfs-$(HOST_MKCRAMFS_VER); \
		$(MAKE) all
		cp $(BUILD_TMP)/cramfs-$(HOST_MKCRAMFS_VER)/mkcramfs $(HOST_DIR)/bin
		cp $(BUILD_TMP)/cramfs-$(HOST_MKCRAMFS_VER)/cramfsck $(HOST_DIR)/bin
	$(REMOVE)/cramfs-$(HOST_MKCRAMFS_VER)
	$(TOUCH)

#
# host_mksquashfs3
#
HOST_MKSQUASHFS3_VER = 3.3
HOST_MKSQUASHFS3_SOURCE = squashfs$(HOST_MKSQUASHFS3_VER).tar.gz

$(ARCHIVE)/$(HOST_MKSQUASHFS3_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/squashfs/files/OldFiles/$(HOST_MKSQUASHFS3_SOURCE)

$(D)/host_mksquashfs3: directories $(ARCHIVE)/$(HOST_MKSQUASHFS3_SOURCE)
	$(START_BUILD)
	$(REMOVE)/squashfs$(HOST_MKSQUASHFS3_VER)
	$(UNTAR)/$(HOST_MKSQUASHFS3_SOURCE)
	$(CHDIR)/squashfs$(HOST_MKSQUASHFS3_VER)/squashfs-tools; \
		$(MAKE) CC=gcc all
		mv $(BUILD_TMP)/squashfs$(HOST_MKSQUASHFS3_VER)/squashfs-tools/mksquashfs $(HOST_DIR)/bin/mksquashfs3.3
		mv $(BUILD_TMP)/squashfs$(HOST_MKSQUASHFS3_VER)/squashfs-tools/unsquashfs $(HOST_DIR)/bin/unsquashfs3.3
	$(REMOVE)/squashfs$(HOST_MKSQUASHFS3_VER)
	$(TOUCH)

#
# host_mksquashfs with LZMA support
#
HOST_MKSQUASHFS_VER = 4.2
HOST_MKSQUASHFS_SOURCE = squashfs$(HOST_MKSQUASHFS_VER).tar.gz

LZMA_VER = 4.65
LZMA_SOURCE = lzma-$(LZMA_VER).tar.bz2

$(ARCHIVE)/$(HOST_MKSQUASHFS_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/squashfs/files/squashfs/squashfs$(HOST_MKSQUASHFS_VER)/$(HOST_MKSQUASHFS_SOURCE)

$(ARCHIVE)/$(LZMA_SOURCE):
	$(DOWNLOAD) http://downloads.openwrt.org/sources/$(LZMA_SOURCE)

$(D)/host_mksquashfs: directories $(ARCHIVE)/$(LZMA_SOURCE) $(ARCHIVE)/$(HOST_MKSQUASHFS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/lzma-$(LZMA_VER)
	$(UNTAR)/$(LZMA_SOURCE)
	$(REMOVE)/squashfs$(HOST_MKSQUASHFS_VER)
	$(UNTAR)/$(HOST_MKSQUASHFS_SOURCE)
	$(CHDIR)/squashfs$(HOST_MKSQUASHFS_VER); \
		$(MAKE) -C squashfs-tools \
			LZMA_SUPPORT=1 \
			LZMA_DIR=$(BUILD_TMP)/lzma-$(LZMA_VER) \
			XATTR_SUPPORT=0 \
			XATTR_DEFAULT=0 \
			install INSTALL_DIR=$(HOST_DIR)/bin
	$(REMOVE)/lzma-$(LZMA_VER)
	$(REMOVE)/squashfs$(HOST_MKSQUASHFS_VER)
	$(TOUCH)

#
# host_resize2fs
#
HOST_E2FSPROGS_VER = $(E2FSPROGS_VER)
HOST_E2FSPROGS_SOURCE = $(E2FSPROGS_SOURCE)

$(D)/host_resize2fs: $(D)/directories $(ARCHIVE)/$(HOST_E2FSPROGS_SOURCE)
	$(START_BUILD)
	$(UNTAR)/$(HOST_E2FSPROGS_SOURCE)
	$(CHDIR)/e2fsprogs-$(HOST_E2FSPROGS_VER); \
		./configure $(SILENT_OPT); \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/e2fsprogs-$(HOST_E2FSPROGS_VER)/resize/resize2fs $(HOST_DIR)/bin/
	install -D -m 0755 $(BUILD_TMP)/e2fsprogs-$(HOST_E2FSPROGS_VER)/misc/mke2fs $(HOST_DIR)/bin/
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext2
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext3
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext4
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext4dev
	install -D -m 0755 $(BUILD_TMP)/e2fsprogs-$(HOST_E2FSPROGS_VER)/e2fsck/e2fsck $(HOST_DIR)/bin/
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext2
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext3
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext4
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext4dev
	$(REMOVE)/e2fsprogs-$(HOST_E2FSPROGS_VER)
	$(TOUCH)

#
# host-gdb
#
$(D)/host-gdb: $(D)/bootstrap $(D)/zlib $(D)/ncurses $(ARCHIVE)/$(GDB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/$(GDB)
	$(UNTAR)/$(GDB_SOURCE)
	$(CHDIR)/$(GDB); \
		./configure $(SILENT_OPT) \
			--host=$(BUILD) \
			--build=$(BUILD) \
			--target=$(TARGET) \
			--prefix=$(HOST_DIR) \
			--mandir=$(TARGET_DIR)/.remove \
			--infodir=$(TARGET_DIR)/.remove \
			--disable-binutils \
			--disable-werror \
			--with-curses \
			--with-zlib \
			--enable-static \
			--with-system-gdbinit=$(HOST_DIR)/share/gdb/gdbinit \
		; \
		$(MAKE) all-gdb; \
		$(MAKE) install-gdb
		echo "handle SIG32 nostop" > $(HOST_DIR)/share/gdb/gdbinit
	$(REMOVE)/$(GDB)
	$(TOUCH)

#
# host_opkg
#
OPKG_VER = 0.3.3
OPKG_SOURCE = opkg-$(OPKG_VER).tar.gz
OPKG_PATCH = opkg-$(OPKG_VER).patch
OPKG_HOST_PATCH = opkg-$(OPKG_VER).patch

$(ARCHIVE)/$(OPKG_SOURCE):
	$(DOWNLOAD) https://git.yoctoproject.org/cgit/cgit.cgi/opkg/snapshot/$(OPKG_SOURCE)

$(D)/host_opkg: directories $(D)/host_libarchive $(ARCHIVE)/$(OPKG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/opkg-$(OPKG_VER)
	$(UNTAR)/$(OPKG_SOURCE)
	$(CHDIR)/opkg-$(OPKG_VER); \
		$(call apply_patches, $(OPKG_HOST_PATCH)); \
		./autogen.sh $(SILENT_OPT); \
		CFLAGS="-I$(HOST_DIR)/include" \
		LDFLAGS="-L$(HOST_DIR)/lib" \
		./configure $(SILENT_OPT) \
			PKG_CONFIG_PATH=$(HOST_DIR)/lib/pkgconfig \
			--prefix= \
			--disable-curl \
			--disable-gpg \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(HOST_DIR)
	$(REMOVE)/opkg-$(OPKG_VER)
	$(TOUCH)

#
# android tools
#
ANDROID_MIRROR = https://android.googlesource.com
HAT_CORE_REV = 2314b11
HAT_CORE_SOURCE = hat-core-git-$(HAT_CORE_REV).tar.bz2
HAT_EXTRAS_REV = 3ecbe8d
HAT_EXTRAS_SOURCE = hat-extras-git-$(HAT_EXTRAS_REV).tar.bz2
#HAT_LIBHARDWARE_REV = be55eb1
#HAT_LIBHARDWARE_SOURCE = hat-libhardware-git-$(HAT_LIBHARDWARE_REV).tar.bz2
HAT_LIBSELINUX_REV = 07e9e13
HAT_LIBSELINUX_SOURCE = hat-libselinux-git-$(HAT_LIBSELINUX_REV).tar.bz2
#HAT_BUILD_REV = 16e987d
#HAT_BUILD_SOURCE = hat-build-git-$(HAT_BUILD_REV).tar.bz2

$(ARCHIVE)/$(HAT_CORE_SOURCE):
	$(HELPERS_DIR)/get-git-archive.sh $(ANDROID_MIRROR)/platform/system/core $(HAT_CORE_REV) $(notdir $@) $(ARCHIVE)

$(ARCHIVE)/$(HAT_EXTRAS_SOURCE):
	$(HELPERS_DIR)/get-git-archive.sh $(ANDROID_MIRROR)/platform/system/extras $(HAT_EXTRAS_REV) $(notdir $@) $(ARCHIVE)

#$(ARCHIVE)/$(HAT_LIBHARDWARE_SOURCE):
#	$(HELPERS_DIR)/get-git-archive.sh $(ANDROID_MIRROR)/platform/hardware/libhardware $(HAT_LIBHARDWARE_REV) $(notdir $@) $(ARCHIVE)

$(ARCHIVE)/$(HAT_LIBSELINUX_SOURCE):
	$(HELPERS_DIR)/get-git-archive.sh $(ANDROID_MIRROR)/platform/external/libselinux $(HAT_LIBSELINUX_REV) $(notdir $@) $(ARCHIVE)

#$(ARCHIVE)/$(HAT_BUILD_SOURCE):
#	$(HELPERS_DIR)/get-git-archive.sh $(ANDROID_MIRROR)/platform/build $(HAT_BUILD_REV) $(notdir $@) $(ARCHIVE)

$(D)/host_atools: $(ARCHIVE)/$(HAT_CORE_SOURCE) $(ARCHIVE)/$(HAT_EXTRAS_SOURCE) $(ARCHIVE)/$(HAT_LIBHARDWARE_SOURCE) $(ARCHIVE)/$(HAT_LIBSELINUX_SOURCE) $(ARCHIVE)/$(HAT_BUILD_SOURCE)
	$(START_BUILD)
	$(REMOVE)/hat
	$(MKDIR)/hat/system/core
	$(SILENT)tar --strip 1 -C $(BUILD_TMP)/hat/system/core -xf $(ARCHIVE)/$(HAT_CORE_SOURCE)
	$(MKDIR)/hat/system/extras
	$(SILENT)tar --strip 1 -C $(BUILD_TMP)/hat/system/extras -xf $(ARCHIVE)/$(HAT_EXTRAS_SOURCE)
	#$(MKDIR)/hat/hardware/libhardware
	#$(SILENT)tar --strip 1 -C $(BUILD_TMP)/hat/hardware/libhardware -xf $(ARCHIVE)/$(HAT_LIBHARDWARE_SOURCE)
	$(MKDIR)/hat/external/libselinux
	$(SILENT)tar --strip 1 -C $(BUILD_TMP)/hat/external/libselinux -xf $(ARCHIVE)/$(HAT_LIBSELINUX_SOURCE)
	#$(MKDIR)/hat/build
	#$(SILENT)tar --strip 1 -C $(BUILD_TMP)/hat/build -xf $(ARCHIVE)/$(HAT_BUILD_SOURCE)
	cp $(PATCHES)/ext4_utils.mk $(BUILD_TMP)/hat
	$(CHDIR)/hat; \
		$(MAKE) --file=ext4_utils.mk SRCDIR=$(BUILD_TMP)/hat
		install -D -m 0755 $(BUILD_TMP)/hat/ext2simg $(HOST_DIR)/bin/
		install -D -m 0755 $(BUILD_TMP)/hat/ext4fixup $(HOST_DIR)/bin/
		install -D -m 0755 $(BUILD_TMP)/hat/img2simg $(HOST_DIR)/bin/
		install -D -m 0755 $(BUILD_TMP)/hat/make_ext4fs $(HOST_DIR)/bin/
		install -D -m 0755 $(BUILD_TMP)/hat/simg2img $(HOST_DIR)/bin/
		install -D -m 0755 $(BUILD_TMP)/hat/simg2simg $(HOST_DIR)/bin/
	$(REMOVE)/hat
	$(TOUCH)

#
# host-ccache
#
HOST_CCACHE_BIN    = $(CCACHE)
HOST_CCACHE_BINDIR = $(HOST_DIR)/bin

HOST_CCACHE_LINKS = \
	ln -sf $(HOST_CCACHE_BIN) $(HOST_CCACHE_BINDIR)/cc; \
	ln -sf $(HOST_CCACHE_BIN) $(HOST_CCACHE_BINDIR)/gcc; \
	ln -sf $(HOST_CCACHE_BIN) $(HOST_CCACHE_BINDIR)/g++; \
	ln -sf $(HOST_CCACHE_BIN) $(HOST_CCACHE_BINDIR)/$(TARGET)-gcc; \
	ln -sf $(HOST_CCACHE_BIN) $(HOST_CCACHE_BINDIR)/$(TARGET)-g++

HOST_CCACHE_ENV = \
	install -d $(HOST_CCACHE_BINDIR); \
	$(HOST_CCACHE_LINKS)

$(D)/host_ccache:
	$(START_BUILD)
	$(HOST_CCACHE_ENV)
	$(TOUCH)

# hack to make sure they are always copied
PHONY += host_ccache
