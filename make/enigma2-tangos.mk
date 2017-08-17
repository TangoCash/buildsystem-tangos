#
# enigma2-tc-deps
#
ENIGMA2_TC_DEPS  = bootstrap ncurses libcurl libpng libjpeg giflib freetype libfribidi libsigc readline
ENIGMA2_TC_DEPS += expat libdvbsi python libxml2 libxslt python_elementtree python_lxml python_zope_interface
ENIGMA2_TC_DEPS += python_twisted python_pyopenssl python_imaging python_pyusb python_pycrypto python_pyasn1 python_mechanize python_six
ENIGMA2_TC_DEPS += python_requests python_futures python_singledispatch python_livestreamer python_livestreamersrv
ENIGMA2_TC_DEPS += libdreamdvd enigma2_tuxtxt32bpp enigma2_hotplug_e2_helper opkg ethtool
ENIGMA2_TC_DEPS += $(MEDIAFW_DEP) $(EXTERNALLCD_DEP)

E2_OBJDIR=$(OBJDIR)/enigma2
E2_BRANCH="master"
E2_REPO="https://github.com/TangoCash/tangos-enigma2.git"

#
# yaud-enigma2-tangos
#
yaud-enigma2-tangos: yaud-none host_python enigma2-tangos enigma2-plugins release_enigma2
	$(TUXBOX_YAUD_CUSTOMIZE)

$(D)/enigma2-tangos.do_rebuild: python
	[ -d "$(D)/libxml2" ] || rm -rf $(D)/libxml2; \
	$(MAKE) IMAGE=enigma2 libxml2
	
$(D)/enigma2-tangos.do_prepare: | $(ENIGMA2_TC_DEPS)
	rm -rf $(SOURCE_DIR)/enigma2-tangos; \
	rm -rf $(SOURCE_DIR)/enigma2-tangos.org; \
	[ -d "$(ARCHIVE)/enigma2-tangos.git" ] && \
	(cd $(ARCHIVE)/enigma2-tangos.git; git pull; git checkout "$$BRANCH"; git checkout HEAD; git pull; cd "$(buildprefix)";); \
	[ -d "$(ARCHIVE)/enigma2-tangos.git" ] || \
	git clone -b $(E2_BRANCH) $(E2_REPO) $(ARCHIVE)/enigma2-tangos.git; \
	cp -ra $(ARCHIVE)/enigma2-tangos.git $(SOURCE_DIR)/enigma2-tangos; \
	cp -ra $(SOURCE_DIR)/enigma2-tangos $(SOURCE_DIR)/enigma2-tangos.org;
	touch $@
	
$(D)/enigma2-tangos.config.status:
	rm -rf $(E2_OBJDIR)
	test -d $(E2_OBJDIR) || mkdir -p $(E2_OBJDIR) && \
	cd $(E2_OBJDIR) && \
		$(SOURCE_DIR)/enigma2-tangos/autogen.sh && \
		$(BUILDENV) \
		$(SOURCE_DIR)/enigma2-tangos/configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--with-libsdl=no \
			--datadir=/usr/local/share \
			--libdir=/usr/lib \
			--bindir=/usr/local/bin \
			--prefix=/usr \
			--sysconfdir=/etc \
			--with-boxtype=none \
			--enable-libeplayer3 \
			--enable-sigc2 \
			--with-alsa \
			PKG_CONFIG=$(HOST_DIR)/bin/$(TARGET)-pkg-config \
			PKG_CONFIG_PATH=$(TARGET_DIR)/usr/lib/pkgconfig \
			PY_PATH=$(TARGET_DIR)/usr \
			$(PLATFORM_CPPFLAGS)

$(SOURCE_DIR)/enigma2-tangos/main/version.h:
	@rm -f $@
	@if test -d $(SOURCE_DIR)/enigma2-tangos ; then \
		pushd $(SOURCE_DIR)/enigma2-tangos ; \
		ENIGMA2_COMMIT_DATE = $$(git log --no-color -n 1 --pretty=format:%cd --date=short); \
		ENIGMA2_BRANCH = $(E2_BRANCH); \
		ENIGMA2_REV = $$(git log | grep "^commit" | wc -l); \
		popd ; \
		echo '#define ENIGMA2_COMMIT_DATE "'$$ENIGMA2_COMMIT_DATE'"' >  $@ ; \
		echo '#define ENIGMA2_BRANCH "'$$ENIGMA2_BRANCH'"' >> $@ ; \
		echo '#define ENIGMA2_REV "'$$ENIGMA2_REV'"' >> $@ ; \
	fi

$(D)/enigma2-tangos.do_compile: $(D)/enigma2-tangos.config.status $(SOURCE_DIR)/enigma2-tangos/main/version.h
	cd $(SOURCE_DIR)/enigma2-tangos && \
		$(MAKE) -C $(E2_OBJDIR) all
	touch $@

$(D)/enigma2-tangos: enigma2-tangos.do_rebuild enigma2-tangos.do_prepare enigma2-tangos.do_compile
	$(TARGET)-strip --strip-unneeded $(E2_OBJDIR)/main/enigma2
	$(MAKE) -C $(E2_OBJDIR) install DESTDIR=$(TARGET_DIR)
	touch $@

enigma2-tangos-clean:
	rm -f $(D)/enigma2-tangos
	cd $(E2_OBJDIR) && \
		$(MAKE) -C $(E2_OBJDIR) distclean

enigma2-tangos-distclean:
	rm -f $(D)/enigma2-tangos*
	rm -rf $(E2_OBJDIR)
	
enigma2-tangos-remake:
	$(MAKE) enigma2-tangos-distclean
	$(MAKE) enigma2-tangos
	
