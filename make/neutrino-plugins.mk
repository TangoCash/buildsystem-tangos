#
# Makefile to build NEUTRINO-PLUGINS
#

#
# links
#
LINKS_VER = 2.20
LINKS_PATCH  = links-$(LINKS_VER).patch
LINKS_PATCH += links-$(LINKS_VER)-ac-prog-cxx.patch
LINKS_PATCH += links-$(LINKS_VER)-accept_https_play.patch
LINKS_PATCH += $(LINKS_PATCH_BOXTYPE)

$(ARCHIVE)/links-$(LINKS_VER).tar.bz2:
	$(DOWNLOAD) http://links.twibright.com/download/links-$(LINKS_VER).tar.bz2

$(D)/links: $(D)/bootstrap $(D)/freetype $(D)/libpng $(D)/libjpeg $(D)/openssl $(ARCHIVE)/links-$(LINKS_VER).tar.bz2
	$(START_BUILD)
	$(REMOVE)/links-$(LINKS_VER)
	$(UNTAR)/links-$(LINKS_VER).tar.bz2
	$(CHDIR)/links-$(LINKS_VER); \
		$(call apply_patches, $(LINKS_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--with-libjpeg \
			--without-libtiff \
			--without-svgalib \
			--without-lzma \
			--with-fb \
			--without-directfb \
			--without-pmshell \
			--without-atheos \
			--without-libfontconfig \
			--enable-graphics \
			--with-ssl=$(TARGET_DIR)/usr \
			--without-x \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/var/tuxbox/plugins $(TARGET_DIR)/var/tuxbox/config/links
	mv $(TARGET_DIR)/bin/links $(TARGET_DIR)/var/tuxbox/plugins/links.so
	echo "name=Links Web Browser"	 > $(TARGET_DIR)/var/tuxbox/plugins/links.cfg
	echo "desc=Web Browser"		>> $(TARGET_DIR)/var/tuxbox/plugins/links.cfg
	echo "type=2"			>> $(TARGET_DIR)/var/tuxbox/plugins/links.cfg
	echo "bookmarkcount=0"		 > $(TARGET_DIR)/var/tuxbox/config/bookmarks
	touch $(TARGET_DIR)/var/tuxbox/config/links/links.his
	cp -a $(SKEL_ROOT)/var/tuxbox/config/links/bookmarks.html $(SKEL_ROOT)/var/tuxbox/config/links/tables.tar.gz $(TARGET_DIR)/var/tuxbox/config/links
	$(REMOVE)/links-$(LINKS_VER)
	$(TOUCH)

#
# neutrino-plugins
#

NP_OBJDIR = $(BUILD_TMP)/neutrino-plugins

$(D)/neutrino-plugins.do_prepare: $(D)/bootstrap $(D)/ffmpeg $(D)/libcurl $(D)/libpng $(D)/libjpeg $(D)/giflib $(D)/freetype
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrino-plugins
	rm -rf $(SOURCE_DIR)/neutrino-plugins.org
	set -e; if [ -d $(ARCHIVE)/neutrino-plugins-ddt.git ]; \
		then cd $(ARCHIVE)/neutrino-plugins-ddt.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/Duckbox-Developers/neutrino-ddt-plugins.git neutrino-plugins-ddt.git; \
		fi
	cp -ra $(ARCHIVE)/neutrino-plugins-ddt.git $(SOURCE_DIR)/neutrino-plugins
	sed -i -e 's#shellexec fx2#shellexec#g' $(SOURCE_DIR)/neutrino-plugins/Makefile.am
	sed -i -e 's#stb-startup \\#stb-startup-tuxbox \\#g' $(SOURCE_DIR)/neutrino-plugins/Makefile.am
	cp -ra $(SOURCE_DIR)/neutrino-plugins $(SOURCE_DIR)/neutrino-plugins.org
	@touch $@

$(D)/neutrino-plugins.config.status:
	rm -rf $(NP_OBJDIR)
	test -d $(NP_OBJDIR) || mkdir -p $(NP_OBJDIR)
	cd $(NP_OBJDIR); \
		$(SOURCE_DIR)/neutrino-plugins/autogen.sh $(SILENT_OPT) && automake --add-missing $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/neutrino-plugins/configure $(SILENT_OPT) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--enable-maintainer-mode \
			--enable-silent-rules \
			\
			--with-target=cdk \
			--include=/usr/include \
			--with-boxtype=$(BOXTYPE) \
			--with-plugindir=/var/tuxbox/plugins \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(N_CPPFLAGS) $(EXTRA_CPPFLAGS_MP_PLUGINS) -DNEW_LIBCURL" \
			LDFLAGS="$(TARGET_LDFLAGS) -L$(NP_OBJDIR)/fx2/lib/.libs"
	@touch $@

$(D)/neutrino-plugins.do_compile: $(D)/neutrino-plugins.config.status
	$(MAKE) -C $(NP_OBJDIR) DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/neutrino-plugins: $(D)/neutrino-plugins.do_prepare $(D)/neutrino-plugins.do_compile
	mkdir -p $(TARGET_SHARE_DIR)/tuxbox/neutrino/icons
	$(MAKE) -C $(NP_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

neutrino-plugins-clean:
	rm -f $(D)/neutrino-plugins
	rm -f $(D)/neutrino-plugins
	rm -f $(D)/neutrino-plugins.config.status
	cd $(NP_OBJDIR); \
		$(MAKE) -C $(NP_OBJDIR) clean

neutrino-plugins-distclean:
	rm -rf $(NP_OBJDIR)
	rm -f $(D)/neutrino-plugin*

#
# xupnpd
#
XUPNPD_BRANCH = 25d6d44c045
XUPNPD_PATCH = xupnpd.patch

$(D)/xupnpd \
$(D)/neutrino-plugin-xupnpd: $(D)/bootstrap $(D)/lua $(D)/openssl $(D)/neutrino-plugin-scripts-lua
	$(START_BUILD)
	$(REMOVE)/xupnpd
	set -e; if [ -d $(ARCHIVE)/xupnpd.git ]; \
		then cd $(ARCHIVE)/xupnpd.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/clark15b/xupnpd.git xupnpd.git; \
		fi
	cp -ra $(ARCHIVE)/xupnpd.git $(BUILD_TMP)/xupnpd
	($(CHDIR)/xupnpd; git checkout -q $(XUPNPD_BRANCH);)
	$(CHDIR)/xupnpd; \
		$(call apply_patches, $(XUPNPD_PATCH))
	$(CHDIR)/xupnpd/src; \
		$(BUILDENV) \
		$(MAKE) embedded TARGET=$(TARGET) PKG_CONFIG=$(PKG_CONFIG) LUAFLAGS="$(TARGET_LDFLAGS) -I$(TARGET_INCLUDE_DIR)"; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	install -m 755 $(SKEL_ROOT)/etc/init.d/xupnpd $(TARGET_DIR)/etc/init.d/
	mkdir -p $(TARGET_SHARE_DIR)/xupnpd/config
	rm $(TARGET_SHARE_DIR)/xupnpd/plugins/staff/xupnpd_18plus.lua
	install -m 644 $(ARCHIVE)/tuxbox-scripts-lua.git/xupnpd/xupnpd_18plus.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	install -m 644 $(ARCHIVE)/tuxbox-scripts-lua.git/xupnpd/xupnpd_cczwei.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	: install -m 644 $(ARCHIVE)/tuxbox-scripts-lua.git/xupnpd/xupnpd_coolstream.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	install -m 644 $(ARCHIVE)/tuxbox-scripts-lua.git/xupnpd/xupnpd_youtube.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	$(REMOVE)/xupnpd
	$(TOUCH)

#
# neutrino-plugin-scripts-lua
#
NEUTRINO_SCRIPTLUA_PATCH =

$(D)/neutrino-plugin-scripts-lua: $(D)/bootstrap
	$(START_BUILD)
	$(REMOVE)/neutrino-plugin-scripts-lua
	set -e; if [ -d $(ARCHIVE)/tuxbox-scripts-lua.git ]; \
		then cd $(ARCHIVE)/tuxbox-scripts-lua.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/tuxbox-neutrino/plugin-scripts-lua.git tuxbox-scripts-lua.git; \
		fi
	cp -ra $(ARCHIVE)/tuxbox-scripts-lua.git/plugins $(BUILD_TMP)/neutrino-plugin-scripts-lua
	$(CHDIR)/neutrino-plugin-scripts-lua; \
		$(call apply_patches, $(NEUTRINO_SCRIPTLUA_PATCH))
	$(CHDIR)/neutrino-plugin-scripts-lua; \
		install -d $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins
		install -d $(TARGET_SHARE_DIR)/tuxbox/neutrino/webtv
#		cp -R $(BUILD_TMP)/neutrino-plugin-scripts-lua/ard_mediathek/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
#		cp -R $(BUILD_TMP)/neutrino-plugin-scripts-lua/favorites2bin/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
		cp -R $(BUILD_TMP)/neutrino-plugin-scripts-lua/mtv/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
#		cp -R $(BUILD_TMP)/neutrino-plugin-scripts-lua/netzkino/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
		cp -R $(BUILD_TMP)/neutrino-plugin-scripts-lua/2webTVxml/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
		cp -R $(BUILD_TMP)/neutrino-plugin-scripts-lua/webtv/best_bitrate_m3u8.lua $(TARGET_SHARE_DIR)/tuxbox/neutrino/webtv/
	$(REMOVE)/neutrino-plugin-scripts-lua
	$(TOUCH)

#
# neutrino-mediathek
#
NEUTRINO_MEDIATHEK_PATCH = neutrino-mediathek.patch

$(D)/neutrino-plugin-mediathek:
	$(START_BUILD)
	$(REMOVE)/neutrino-mediathek
	set -e; if [ -d $(ARCHIVE)/neutrino-mediathek.git ]; \
		then cd $(ARCHIVE)/neutrino-mediathek.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/neutrino-mediathek/mediathek.git neutrino-mediathek.git; \
		fi
	cp -ra $(ARCHIVE)/neutrino-mediathek.git $(BUILD_TMP)/neutrino-mediathek
	install -d $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins
	$(CHDIR)/neutrino-mediathek; \
		$(call apply_patches, $(NEUTRINO_MEDIATHEK_PATCH))
	$(CHDIR)/neutrino-mediathek; \
		cp -a plugins/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/; \
		cp -a share $(TARGET_DIR)/usr/
	$(REMOVE)/neutrino-mediathek
	$(TOUCH)

#
# neutrino-iptvplayer
#
$(D)/neutrino-plugin-iptvplayer-nightly \
$(D)/neutrino-plugin-iptvplayer: $(D)/librtmp $(D)/python_twisted_small
	$(START_BUILD)
	$(REMOVE)/iptvplayer
	set -e; if [ -d $(ARCHIVE)/iptvplayer.git ]; \
		then cd $(ARCHIVE)/iptvplayer.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/TangoCash/crossplatform_iptvplayer.git iptvplayer.git; \
		fi
	cp -ra $(ARCHIVE)/iptvplayer.git $(BUILD_TMP)/iptvplayer
	@if [ "$@" = "$(D)/neutrino-plugin-iptvplayer-nightly" ]; then \
		$(BUILD_TMP)/iptvplayer/SyncWithGitLab.sh $(BUILD_TMP)/iptvplayer; \
	fi
	install -d $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins
	install -d $(TARGET_SHARE_DIR)/E2emulator
	cp -R $(BUILD_TMP)/iptvplayer/E2emulator/* $(TARGET_SHARE_DIR)/E2emulator/
	install -d $(TARGET_SHARE_DIR)/E2emulator/Plugins/Extensions/IPTVPlayer
	cp -R $(BUILD_TMP)/iptvplayer/IPTVplayer/* $(TARGET_SHARE_DIR)/E2emulator//Plugins/Extensions/IPTVPlayer/
	cp -R $(BUILD_TMP)/iptvplayer/IPTVdaemon/* $(TARGET_SHARE_DIR)/E2emulator//Plugins/Extensions/IPTVPlayer/
	chmod 755 $(TARGET_SHARE_DIR)/E2emulator/Plugins/Extensions/IPTVPlayer/cmdlineIPTV.*
	chmod 755 $(TARGET_SHARE_DIR)/E2emulator/Plugins/Extensions/IPTVPlayer/IPTVdaemon.*
	PYTHONPATH=$(TARGET_DIR)/$(PYTHON_DIR) \
	$(HOST_DIR)/bin/python$(PYTHON_VER_MAJOR) -Wi -t -O $(TARGET_DIR)/$(PYTHON_DIR)/compileall.py \
		-d /usr/share/E2emulator -f -x badsyntax $(TARGET_SHARE_DIR)/E2emulator
	cp -R $(BUILD_TMP)/iptvplayer/addon4neutrino/neutrinoIPTV/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
	$(REMOVE)/iptvplayer
	$(TOUCH)

#
# fred_feuerstein's channellogos
#
$(D)/neutrino-plugin-channellogos:
	$(START_BUILD)
	$(REMOVE)/channellogos
#	set -e; if [ -d $(ARCHIVE)/channellogos.git ]; \
#		then cd $(ARCHIVE)/channellogos.git; git pull; \
#		else cd $(ARCHIVE); git clone https://github.com/neutrino-images/ni-logo-stuff.git channellogos.git; \
#		fi
#	cp -ra $(ARCHIVE)/channellogos.git $(BUILD_TMP)/channellogos
	git clone https://github.com/neutrino-images/ni-logo-stuff.git $(BUILD_TMP)/channellogos
	rm -rf $(TARGET_SHARE_DIR)/tuxbox/neutrino/icons/logo
	install -d $(TARGET_SHARE_DIR)/tuxbox/neutrino/icons/logo
	install -m 0644 $(BUILD_TMP)/channellogos/logos/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/icons/logo
	install -d $(TARGET_SHARE_DIR)/tuxbox/neutrino/icons/logo/events
	install -m 0644 $(BUILD_TMP)/channellogos/logos-events/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/icons/logo/events
	cd $(BUILD_TMP)/channellogos/logo-links && \
		./logo-linker.sh logo-links.db $(TARGET_SHARE_DIR)/tuxbox/neutrino/icons/logo
	install -d $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins
	cp -a $(BUILD_TMP)/channellogos/logo-addon/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
	$(REMOVE)/channellogos
	$(TOUCH)

#
# annie's lcd4linux skins
#
$(D)/neutrino-plugin-l4l-skins:
	$(START_BUILD)
	$(REMOVE)/l4l-skins
	set -e; if [ -d $(ARCHIVE)/l4l-skins.git ]; \
		then cd $(ARCHIVE)/l4l-skins.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/TangoCash/SamsungLCD4Linux.git l4l-skins.git; \
		fi
	cp -ra $(ARCHIVE)/l4l-skins.git $(BUILD_TMP)/l4l-skins
	install -m 0600 $(BUILD_TMP)/l4l-skins/tango/etc/lcd4linux.conf $(TARGET_DIR)/etc
	install -d $(TARGET_SHARE_DIR)/lcd/icons
	cp -aR $(BUILD_TMP)/l4l-skins/tango/share/* $(TARGET_SHARE_DIR)
	install -d $(TARGET_DIR)/var/lcd
	cp -aR $(BUILD_TMP)/l4l-skins/tango/var/lcd/* $(TARGET_DIR)/var/lcd
	$(REMOVE)/l4l-skins
	$(TOUCH)

#
# annie's settingsupdater
#
$(D)/neutrino-plugin-settings-update:
	$(START_BUILD)
	$(REMOVE)/settings-update
	set -e; if [ -d $(ARCHIVE)/settings-update.git ]; \
		then cd $(ARCHIVE)/settings-update.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/horsti58/lua-data.git settings-update.git; \
		fi
	cp -ra $(ARCHIVE)/settings-update.git $(BUILD_TMP)/settings-update
	cp -R $(BUILD_TMP)/settings-update/lua/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
	$(REMOVE)/settings-update
	$(TOUCH)

#
# lua-custom-plugins
#
$(D)/neutrino-plugin-custom:
	$(START_BUILD)
	$(REMOVE)/plugins-lua
	set -e; if [ -d $(ARCHIVE)/plugins-lua-custom.git ]; \
		then cd $(ARCHIVE)/plugins-lua-custom.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/bazi-98/plugins.git plugins-lua-custom.git; \
		fi
	cp -ra $(ARCHIVE)/plugins-lua-custom.git $(BUILD_TMP)/plugins-lua
	$(CHDIR)/plugins-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/plugins-lua/*/*.cfg $(TARGET_DIR)/var/tuxbox/plugins/
		cp -R $(BUILD_TMP)/plugins-lua/*/*.lua $(TARGET_DIR)/var/tuxbox/plugins/
		cp -R $(BUILD_TMP)/plugins-lua/*/*hint.png $(TARGET_DIR)/var/tuxbox/plugins/
		cp -R $(BUILD_TMP)/plugins-lua/*/*.sh $(TARGET_DIR)/var/tuxbox/plugins/
		ls $(BUILD_TMP)/plugins-lua/*/*.png | grep -v "hint" | xargs -I {} cp {} $(TARGET_SHARE_DIR)/tuxbox/neutrino/icons/logo
	$(REMOVE)/plugins-lua
	$(TOUCH)

#
# spiegel-tv
#
$(D)/neutrino-plugin-spiegel-tv:
	$(START_BUILD)
	$(REMOVE)/plugins-lua
	set -e; if [ -d $(ARCHIVE)/plugins-lua.git ]; \
		then cd $(ARCHIVE)/plugins-lua.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/plugins-lua.git plugins-lua.git; \
		fi
	cp -ra $(ARCHIVE)/plugins-lua.git $(BUILD_TMP)/plugins-lua
	$(CHDIR)/plugins-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/plugins-lua/spiegel-tv-doc/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
	$(REMOVE)/plugins-lua
	$(TOUCH)

#
# tierwelt-tv
#
$(D)/neutrino-plugin-tierwelt-tv:
	$(START_BUILD)
	$(REMOVE)/plugins-lua
	set -e; if [ -d $(ARCHIVE)/plugins-lua.git ]; \
		then cd $(ARCHIVE)/plugins-lua.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/plugins-lua.git plugins-lua.git; \
		fi
	cp -ra $(ARCHIVE)/plugins-lua.git $(BUILD_TMP)/plugins-lua
	$(CHDIR)/plugins-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/plugins-lua/tierwelt-tv/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
	$(REMOVE)/plugins-lua
	$(TOUCH)

#
# mtv
#
$(D)/neutrino-plugin-mtv:
	$(START_BUILD)
	$(REMOVE)/plugins-lua
	set -e; if [ -d $(ARCHIVE)/plugins-lua.git ]; \
		then cd $(ARCHIVE)/plugins-lua.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/plugins-lua.git plugins-lua.git; \
		fi
	cp -ra $(ARCHIVE)/plugins-lua.git $(BUILD_TMP)/plugins-lua
	$(CHDIR)/plugins-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/plugins-lua/mtv/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
	$(REMOVE)/plugins-lua
	$(TOUCH)

#
# neutrino-hd2 plugins
#
NEUTRINO_HD2_PLUGINS_PATCHES =

$(D)/neutrino-hd2-plugins.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrino-hd2-plugins
	ln -s $(SOURCE_DIR)/neutrino-hd2.git/plugins $(SOURCE_DIR)/neutrino-hd2-plugins
	set -e; cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
		$(call apply_patches, $(NEUTRINO_HD2_PLUGINS_PATCHES))
	@touch $@

$(D)/neutrino-hd2-plugins.config.status: $(D)/bootstrap neutrino-hd2
	cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
		./autogen.sh; \
		$(BUILDENV) \
		./configure $(SILENT_OPT) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			--with-plugindir=/var/tuxbox/plugins \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--enable-silent-rules \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(CPPFLAGS) -I$(driverdir) -I$(KERNEL_DIR)/include -I$(TARGET_DIR)/include" \
			LDFLAGS="$(TARGET_LDFLAGS)"
	@touch $@

$(D)/neutrino-hd2-plugins.do_compile: $(D)/neutrino-hd2-plugins.config.status
	cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
	$(MAKE) top_srcdir=$(SOURCE_DIR)/neutrino-hd2
	@touch $@

$(D)/neutrino-hd2-plugins.build: neutrino-hd2-plugins.do_prepare neutrino-hd2-plugins.do_compile
	$(MAKE) -C $(SOURCE_DIR)/neutrino-hd2-plugins install DESTDIR=$(TARGET_DIR) top_srcdir=$(SOURCE_DIR)/neutrino-hd2
	$(TOUCH)

neutrino-hd2-plugins-clean:
	cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
	$(MAKE) clean
	rm -f $(D)/neutrino-hd2-plugins.build
	rm -f $(D)/neutrino-hd2-plugins.config.status

neutrino-hd2-plugins-distclean:
	rm -f $(D)/neutrino-hd2-plugins.build
	rm -f $(D)/neutrino-hd2-plugins.config.status
	rm -f $(D)/neutrino-hd2-plugins.do_prepare
	rm -f $(D)/neutrino-hd2-plugins.do_compile
