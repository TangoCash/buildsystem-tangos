#
# makefile to build development-tools
#
# -----------------------------------------------------------------------------

#
# valgrind
#
VALGRIND_VER    = 3.13.0
VALGRIND        = valgrind-$(VALGRIND_VER)
VALGRIND_SOURCE = valgrind-$(VALGRIND_VER).tar.bz2
VALGRIND_URL    = ftp://sourceware.org/pub/valgrind

$(ARCHIVE)/$(VALGRIND_SOURCE):
	$(DOWNLOAD) $(VALGRIND_URL)/$(VALGRIND_SOURCE)

$(D)/valgrind: $(D)/bootstrap $(ARCHIVE)/$(VALGRIND_SOURCE)
	$(START_BUILD)
	$(REMOVE)/$(VALGRIND)
	$(UNTAR)/$(VALGRIND_SOURCE)
	$(CHDIR)/$(VALGRIND); \
		sed -i -e "s#armv7#arm#g" configure; \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--datadir=/.remove \
			-enable-only32bit \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -f $(addprefix $(TARGET_LIB_DIR)/valgrind/,*.a *.xml)
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,cg_* callgrind_* ms_print)
	$(REMOVE)/$(VALGRIND)
	$(TOUCH)

#
# strace
#
STRACE_VER    = 5.1
STRACE        = strace-$(STRACE_VER)
STRACE_SOURCE = strace-$(STRACE_VER).tar.xz
STRACE_URL    = https://strace.io/files/$(STRACE_VER)

$(ARCHIVE)/$(STRACE_SOURCE):
	$(DOWNLOAD) $(STRACE_URL)/$(STRACE_SOURCE)

$(D)/strace: $(D)/bootstrap $(ARCHIVE)/$(STRACE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/$(STRACE)
	$(UNTAR)/$(STRACE_SOURCE)
	$(CHDIR)/$(STRACE); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--enable-silent-rules \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,strace-graph strace-log-merge)
	$(REMOVE)/$(STRACE)
	$(TOUCH)

#
# gdb
#
GDB_VER    = 8.1.1
GDB        = gdb-$(GDB_VER)
GDB_SOURCE = gdb-$(GDB_VER).tar.xz
GDB_URL    = https://sourceware.org/pub/gdb/releases

$(ARCHIVE)/$(GDB_SOURCE):
	$(DOWNLOAD) $(GDB_URL)/$(GDB_SOURCE)

$(D)/gdb: $(D)/bootstrap $(D)/zlib $(D)/ncurses $(ARCHIVE)/$(GDB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/$(GDB)
	$(UNTAR)/$(GDB_SOURCE)
	$(CHDIR)/$(GDB); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--infodir=/.remove \
			--disable-binutils \
			--disable-werror \
			--with-curses \
			--with-zlib \
			--enable-static \
			--with-system-gdbinit=/usr/share/gdb/gdbinit \
		; \
		$(MAKE) all-gdb; \
		$(MAKE) install-gdb DESTDIR=$(TARGET_DIR)
	rm -rf $(addprefix $(TARGET_SHARE_DIR)/gdb/,system-gdbinit)
	find $(TARGET_SHARE_DIR)/gdb/syscalls -type f -not -name 'arm-linux.xml' -not -name 'gdb-syscalls.dtd' -print0 | xargs -0 rm --
	echo "handle SIG32 nostop" > $(TARGET_SHARE_DIR)/gdb/gdbinit
	$(REMOVE)/$(GDB)
	$(TOUCH)
