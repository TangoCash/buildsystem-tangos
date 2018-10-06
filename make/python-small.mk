PYTHON_IPTV_DEPS  = $(D)/host_python
PYTHON_IPTV_DEPS += $(D)/python-small
PYTHON_IPTV_DEPS += $(D)/python_twisted-small

$(D)/python-small: $(D)/bootstrap $(D)/host_python $(D)/ncurses $(D)/zlib $(D)/openssl $(D)/libffi $(D)/bzip2 $(ARCHIVE)/$(PYTHON_SOURCE)
	$(START_BUILD)
	$(REMOVE)/Python-$(PYTHON_VER)
	$(UNTAR)/$(PYTHON_SOURCE)
	set -e; cd $(BUILD_TMP)/Python-$(PYTHON_VER); \
		$(call apply_patches,$(PYTHON_PATCH)); \
		CONFIG_SITE= \
		$(BUILDENV) \
		autoreconf -fiv Modules/_ctypes/libffi; \
		autoconf $(SILENT_OPT); \
		./configure $(SILENT_OPT) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix=/usr \
			--mandir=/.remove \
			--sysconfdir=/etc \
			--enable-shared \
			--with-lto \
			--enable-ipv6 \
			--with-threads \
			--with-pymalloc \
			--with-signal-module \
			--with-wctype-functions \
			ac_sys_system=Linux \
			ac_sys_release=2 \
			ac_cv_file__dev_ptmx=no \
			ac_cv_file__dev_ptc=no \
			ac_cv_have_long_long_format=yes \
			ac_cv_no_strict_aliasing_ok=yes \
			ac_cv_pthread=yes \
			ac_cv_cxx_thread=yes \
			ac_cv_sizeof_off_t=8 \
			ac_cv_have_chflags=no \
			ac_cv_have_lchflags=no \
			ac_cv_py_format_size_t=yes \
			ac_cv_broken_sem_getvalue=no \
			HOSTPYTHON=$(HOST_DIR)/bin/python$(PYTHON_VER_MAJOR) \
		; \
		$(MAKE) $(MAKE_OPTS) \
			PYTHON_MODULES_INCLUDE="$(TARGET_DIR)/usr/include" \
			PYTHON_MODULES_LIB="$(TARGET_DIR)/usr/lib" \
			PYTHON_XCOMPILE_DEPENDENCIES_PREFIX="$(TARGET_DIR)" \
			CROSS_COMPILE_TARGET=yes \
			CROSS_COMPILE=$(TARGET) \
			MACHDEP=linux2 \
			HOSTARCH=$(TARGET) \
			CFLAGS="$(TARGET_CFLAGS)" \
			LDFLAGS="$(TARGET_LDFLAGS)" \
			LD="$(TARGET)-gcc" \
			HOSTPYTHON=$(HOST_DIR)/bin/python$(PYTHON_VER_MAJOR) \
			HOSTPGEN=$(HOST_DIR)/bin/pgen \
			all DESTDIR=$(TARGET_DIR) \
		; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	ln -sf ../../libpython$(PYTHON_VER_MAJOR).so.1.0 $(TARGET_DIR)/$(PYTHON_DIR)/config/libpython$(PYTHON_VER_MAJOR).so; \
	ln -sf $(TARGET_DIR)/$(PYTHON_INCLUDE_DIR) $(TARGET_DIR)/usr/include/python
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/python-2.7.pc
	$(REMOVE)/Python-$(PYTHON_VER)
	$(TOUCH)

$(D)/python_twisted-small: $(D)/bootstrap $(D)/python-small $(D)/python_setuptools-small $(D)/python_zope_interface-small $(ARCHIVE)/$(PYTHON_TWISTED_SOURCE)
	$(START_BUILD)
	$(REMOVE)/Twisted-$(PYTHON_TWISTED_VER)
	$(UNTAR)/$(PYTHON_TWISTED_SOURCE)
	set -e; cd $(BUILD_TMP)/Twisted-$(PYTHON_TWISTED_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/Twisted-$(PYTHON_TWISTED_VER)
	$(TOUCH)

$(D)/python_setuptools-small: $(D)/bootstrap $(D)/python-small $(ARCHIVE)/$(PYTHON_SETUPTOOLS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/setuptools-$(PYTHON_SETUPTOOLS_VER)
	$(UNTAR)/$(PYTHON_SETUPTOOLS_SOURCE)
	set -e; cd $(BUILD_TMP)/setuptools-$(PYTHON_SETUPTOOLS_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/setuptools-$(PYTHON_SETUPTOOLS_VER)
	$(TOUCH)

$(D)/python_zope_interface-small: $(D)/bootstrap $(D)/python-small $(D)/python_setuptools-small $(ARCHIVE)/$(PYTHON_ZOPE_INTERFACE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/zope.interface-$(PYTHON_ZOPE_INTERFACE_VER)
	$(UNTAR)/$(PYTHON_ZOPE_INTERFACE_SOURCE)
	set -e; cd $(BUILD_TMP)/zope.interface-$(PYTHON_ZOPE_INTERFACE_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/zope.interface-$(PYTHON_ZOPE_INTERFACE_VER)
	$(TOUCH)

python-iptv: $(PYTHON_IPTV_DEPS)

python-iptv-install:
#
# python2.7
#
	if [ $(PYTHON_VER_MAJOR) == 2.7 ]; then \
		install -d $(RELEASE_DIR)/usr/include; \
		install -d $(RELEASE_DIR)/$(PYTHON_INCLUDE_DIR); \
		cp $(TARGET_DIR)/$(PYTHON_INCLUDE_DIR)/pyconfig.h $(RELEASE_DIR)/$(PYTHON_INCLUDE_DIR); \
		cp -P $(TARGET_DIR)/usr/lib/libpython* $(RELEASE_DIR)/usr/lib; \
		cp -P $(TARGET_DIR)/usr/bin/python* $(RELEASE_DIR)/usr/bin; \
	fi

#
# delete unnecessary files python
#
	install -d $(RELEASE_DIR)/$(PYTHON_DIR)
	cp -a $(TARGET_DIR)/$(PYTHON_DIR)/* $(RELEASE_DIR)/$(PYTHON_DIR)/
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/{bsddb,compiler,curses,distutils,lib-old,lib-tk,plat-linux3,test}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/ctypes/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/json/tests
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/{test,conch,mail,names,news,words,flow,lore,pair,runner,_threads,application,cred,enterprise,persisted,plugins,positioning,scripts,spread,tap,trial,web}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/logger/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/Cheetah/Tests
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/livestreamer_cli
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/lxml
	rm -f $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/libxml2mod.so
	rm -f $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/libxsltmod.so
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/OpenSSL/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/setuptools
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/zope/interface/tests
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/application/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/conch/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/internet/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/lore/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/mail/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/manhole/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/names/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/news/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/pair/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/persisted/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/protocols/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/python/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/runner/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/scripts/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/trial/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/web/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/words/test
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/*-py$(PYTHON_VER_MAJOR).egg-info
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/email
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/ensurepip
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/hotshot
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/idlelib
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/lib2to3
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/multiprocessing
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/plat-linux2
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/pydoc_data
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/sqlite3
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/unittest
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/wsgiref
#
# Do not remove pyo files, remove pyc instead
#
	find $(RELEASE_DIR)/$(PYTHON_DIR)/ -name '*.pyc' -exec rm -f {} \;
ifeq ($(OPTIMIZATIONS), size)
	find $(RELEASE_DIR)/$(PYTHON_DIR)/ -name '*.py' -exec rm -f {} \;
endif
	find $(RELEASE_DIR)/$(PYTHON_DIR)/ -name '*.a' -exec rm -f {} \;
	find $(RELEASE_DIR)/$(PYTHON_DIR)/ -name '*.c' -exec rm -f {} \;
	find $(RELEASE_DIR)/$(PYTHON_DIR)/ -name '*.pyx' -exec rm -f {} \;
	find $(RELEASE_DIR)/$(PYTHON_DIR)/ -name '*.o' -exec rm -f {} \;
	find $(RELEASE_DIR)/$(PYTHON_DIR)/ -name '*.la' -exec rm -f {} \;
