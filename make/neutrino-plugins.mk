#
# Makefile to build NEUTRINO-PLUGINS
#

#
# links
#
LINKS_VER = 2.22
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
	mkdir -p $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins $(TARGET_DIR)/var/tuxbox/config/links
	mv $(TARGET_DIR)/bin/links $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/links.so
	echo "name=Links Web Browser"	 > $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/links.cfg
	echo "desc=Web Browser"		>> $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/links.cfg
	echo "type=2"			>> $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/links.cfg
	echo "bookmarkcount=0"		 > $(TARGET_DIR)/var/tuxbox/config/bookmarks
	touch $(TARGET_DIR)/var/tuxbox/config/links/links.his
	cp -a $(SKEL_ROOT)/var/tuxbox/config/links/bookmarks.html $(SKEL_ROOT)/var/tuxbox/config/links/tables.tar.gz $(TARGET_DIR)/var/tuxbox/config/links
	$(REMOVE)/links-$(LINKS_VER)
	$(TOUCH)

#
# neutrino-plugins
#

ifeq ($(FLAVOUR), HD2)
NP_OBJDIR = $(BUILD_TMP)/neutrino-hd2-plugins
else
NP_OBJDIR = $(BUILD_TMP)/neutrino-plugins
endif

$(D)/neutrino-plugins.do_prepare: $(D)/bootstrap $(D)/ffmpeg $(D)/libcurl $(D)/libpng $(D)/libjpeg $(D)/giflib $(D)/freetype
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrino-plugins
	rm -rf $(SOURCE_DIR)/neutrino-plugins.org
	set -e; if [ -d $(ARCHIVE)/neutrino-plugins-tangos.git ]; \
		then cd $(ARCHIVE)/neutrino-plugins-tangos.git; git pull; \
		else cd $(ARCHIVE); git clone $(GITHUB)/TangoCash/neutrino-tangos-plugins.git neutrino-plugins-tangos.git; \
		fi
	cp -ra $(ARCHIVE)/neutrino-plugins-tangos.git $(SOURCE_DIR)/neutrino-plugins
	sed -i -e 's#shellexec fx2#shellexec tuxmail tuxcal#g' $(SOURCE_DIR)/neutrino-plugins/Makefile.am
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd51 h7 bre2ze4k e4hdultra protek4k multibox multiboxse hd60 hd61 osmio4k osmio4kplus sf8008 sf8008m ustym4kpro ustym4ks2ottx h9combo h9))
	sed -i -e 's#stb-startup \\#stb-startup-tuxbox \\#g' $(SOURCE_DIR)/neutrino-plugins/Makefile.am
endif
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
			--with-plugindir=/usr/share/tuxbox/neutrino/plugins \
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
	rm -f $(D)/neutrino-plugins.do_*
	rm -f $(D)/neutrino-plugins.config.status
	cd $(NP_OBJDIR); \
		$(MAKE) -C $(NP_OBJDIR) clean

neutrino-plugins-distclean:
	rm -rf $(NP_OBJDIR)
	rm -f $(D)/neutrino-plugins
	rm -f $(D)/neutrino-plugins.do_*
	rm -f $(D)/neutrino-plugins.config.status

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
		else cd $(ARCHIVE); git clone $(GITHUB)/clark15b/xupnpd.git xupnpd.git; \
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
	install -m 644 $(ARCHIVE)/neutrino-plugin-scripts-lua.git/xupnpd/xupnpd_18plus.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	install -m 644 $(ARCHIVE)/neutrino-plugin-scripts-lua.git/xupnpd/xupnpd_cczwei.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	: install -m 644 $(ARCHIVE)/neutrino-plugin-scripts-lua.git/xupnpd/xupnpd_coolstream.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	install -m 644 $(ARCHIVE)/neutrino-plugin-scripts-lua.git/xupnpd/xupnpd_youtube.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	$(REMOVE)/xupnpd
	$(TOUCH)

#
# neutrino-plugin-scripts-lua
#
NEUTRINO_SCRIPTLUA_GIT = $(GITHUB)/tuxbox-neutrino/plugin-scripts-lua.git
NEUTRINO_SCRIPTLUA_PATCH =

$(D)/neutrino-plugin-scripts-lua: $(D)/bootstrap
	$(START_BUILD)
	$(REMOVE)/$(PKG_NAME)
	$(call update_git, $(NEUTRINO_SCRIPTLUA_GIT))
	$(CHDIR)/$(PKG_NAME); \
		$(call apply_patches, $(NEUTRINO_SCRIPTLUA_PATCH)) ;\
		install -d $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins
		cp -R $(PKG_DIR)/plugins/ard_mediathek/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
		cp -R $(PKG_DIR)/plugins/mtv/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
		cp -R $(PKG_DIR)/plugins/zdfhbbtv/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
		cp -R $(PKG_DIR)/plugins/netzkino/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
#		cp -R $(PKG_DIR)/plugins/2webTVxml/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
#		cp -R $(PKG_DIR)/plugins/favorites2bin/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
		install -d $(TARGET_SHARE_DIR)/tuxbox/neutrino/webtv
		cp -R $(PKG_DIR)/plugins/webtv/best_bitrate_m3u8.lua $(TARGET_SHARE_DIR)/tuxbox/neutrino/webtv/
	$(REMOVE)/$(PKG_NAME)
	$(TOUCH)

#
# neutrino-mediathek
#
NEUTRINO_MEDIATHEK_GIT = $(GITHUB)/neutrino-mediathek/mediathek.git
NEUTRINO_MEDIATHEK_PATCH = neutrino-mediathek.patch

$(D)/neutrino-plugin-mediathek:
	$(START_BUILD)
	$(REMOVE)/$(PKG_NAME)
	$(call update_git, $(NEUTRINO_MEDIATHEK_GIT))
	$(CHDIR)/$(PKG_NAME); \
		$(call apply_patches, $(NEUTRINO_MEDIATHEK_PATCH)) ; \
		cp -a plugins/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/; \
		cp -a share $(TARGET_DIR)/usr/
	$(REMOVE)/$(PKG_NAME)
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
		else cd $(ARCHIVE); git clone $(GITHUB)/TangoCash/crossplatform_iptvplayer.git iptvplayer.git; \
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
#		else cd $(ARCHIVE); git clone $(GITHUB)/neutrino-images/ni-logo-stuff.git channellogos.git; \
#		fi
#	cp -ra $(ARCHIVE)/channellogos.git $(BUILD_TMP)/channellogos
	git clone $(GITHUB)/neutrino-images/ni-logo-stuff.git $(BUILD_TMP)/channellogos
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
L4L_SKINS_GIT = $(GITHUB)/TangoCash/SamsungLCD4Linux.git

$(D)/neutrino-plugin-l4l-skins:
	$(START_BUILD)
	$(REMOVE)/$(PKG_NAME)
	$(call update_git, $(L4L_SKINS_GIT))
	install -m 0600 $(PKG_DIR)/tango/etc/lcd4linux.conf $(TARGET_DIR)/etc
	install -d $(TARGET_SHARE_DIR)/lcd/icons
	cp -aR $(PKG_DIR)/tango/share/* $(TARGET_SHARE_DIR)
	install -d $(TARGET_DIR)/var/lcd
	cp -aR $(PKG_DIR)/tango/var/lcd/* $(TARGET_DIR)/var/lcd
	$(REMOVE)/$(PKG_NAME)
	$(TOUCH)

#
# NI WebTV / Radio
#
$(D)/neutrino-plugin-webtv-radio:
	$(START_BUILD)
	$(REMOVE)/NI-scripts-lua
	set -e; if [ -d $(ARCHIVE)/NI-scripts-lua.git ]; \
		then cd $(ARCHIVE)/NI-scripts-lua.git; git pull origin master; \
		else cd $(ARCHIVE); mkdir NI-scripts-lua.git; cd $(ARCHIVE)/NI-scripts-lua.git; \
		git init; git remote add origin -f $(GITHUB)/neutrino-images/ni-neutrino-plugins.git; \
		git config core.sparseCheckout true ; \
		echo scripts-lua > .git/info/sparse-checkout ; git pull origin master; \
		fi
	install -d $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins
	install -d $(TARGET_SHARE_DIR)/tuxbox/neutrino/webtv
	install -d $(TARGET_SHARE_DIR)/tuxbox/neutrino/webradio
	cp -ra $(ARCHIVE)/NI-scripts-lua.git $(BUILD_TMP)/NI-scripts-lua
	cp -R $(BUILD_TMP)/NI-scripts-lua/scripts-lua/plugins/plutotv-update/plutotv* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
	cp -R $(BUILD_TMP)/NI-scripts-lua/scripts-lua/plugins/plutotv-vod/plutotv* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
	cp -R $(BUILD_TMP)/NI-scripts-lua/scripts-lua/plugins/webtv/plutotv* $(TARGET_SHARE_DIR)/tuxbox/neutrino/webtv/
	cp -R $(BUILD_TMP)/NI-scripts-lua/scripts-lua/plugins/webtv/rakutentv* $(TARGET_SHARE_DIR)/tuxbox/neutrino/webtv/
	cp -R $(BUILD_TMP)/NI-scripts-lua/scripts-lua/plugins/webradio/*.xml $(TARGET_SHARE_DIR)/tuxbox/neutrino/webradio/
	$(REMOVE)/NI-scripts-lua
	$(TOUCH)

#
# annie's settingsupdater
#
SETTINGS_UPDATE_GIT = $(GITHUB)/horsti58/lua-data.git

$(D)/neutrino-plugin-settings-update:
	$(START_BUILD)
	$(REMOVE)/$(PKG_NAME)
	$(call update_git, $(SETTINGS_UPDATE_GIT))
	cp -R $(PKG_DIR)/lua/* $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
	$(REMOVE)/$(PKG_NAME)
	$(TOUCH)

#
# lua-custom-plugins
#
PLUGIN_CUSTOM_GIT = $(GITHUB)/bazi-98/plugins.git

$(D)/neutrino-plugin-custom:
	$(START_BUILD)
	$(REMOVE)/$(PKG_NAME)
	$(call update_git, $(PLUGIN_CUSTOM_GIT))
	$(CHDIR)/$(PKG_NAME); \
		install -d $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins
		cp -R $(PKG_DIR)/*/*.cfg $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
		cp -R $(PKG_DIR)/*/*.lua $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
		cp -R $(PKG_DIR)/*/*hint.png $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
		cp -R $(PKG_DIR)/*/*.sh $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins/
		ls $(PKG_DIR)/*/*.png | grep -v "hint" | xargs -I {} cp {} $(TARGET_SHARE_DIR)/tuxbox/neutrino/icons/logo
	$(REMOVE)/$(PKG_NAME)
	$(TOUCH)

#
# neutrino-hd2 plugins
#
NEUTRINO_HD2_PLUGINS_PATCHES = neutrino-hd2-plugins.patch

EXTRA_HDFLAGS  = -I$(NP_OBJDIR)
EXTRA_HDFLAGS += -I$(SOURCE_DIR)/$(NEUTRINO)/src
EXTRA_HDFLAGS += -I$(SOURCE_DIR)/$(NEUTRINO)/src/zapit/include/zapit
EXTRA_HDFLAGS += -I$(SOURCE_DIR)/$(NEUTRINO)/lib
EXTRA_HDFLAGS += -I$(SOURCE_DIR)/$(NEUTRINO)/lib/connection
EXTRA_HDFLAGS += -I$(SOURCE_DIR)/$(NEUTRINO)/lib/libeventserver
EXTRA_HDFLAGS += -I$(SOURCE_DIR)/$(NEUTRINO)/lib/libconfigfile
EXTRA_HDFLAGS += -I$(SOURCE_DIR)/$(NEUTRINO)/lib/libnet
EXTRA_HDFLAGS += -I$(SOURCE_DIR)/$(NEUTRINO)/lib/libxmltree
EXTRA_HDFLAGS += -I$(SOURCE_DIR)/$(NEUTRINO)/lib/libmd5sum
EXTRA_HDFLAGS += -I$(SOURCE_DIR)/$(NEUTRINO)/lib/libdvbapi

$(D)/neutrino-hd2-plugins.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrino-hd2-plugins
	rm -rf $(SOURCE_DIR)/neutrino-hd2-plugins.org
	rm -rf $(SOURCE_DIR)/neutrino-hd2-plugins.dev
	rm -rf $(NP_OBJDIR)
	cp -ra $(ARCHIVE)/neutrino-hd2.git/plugins $(SOURCE_DIR)/neutrino-hd2-plugins
	cp -ra $(SOURCE_DIR)/neutrino-hd2-plugins $(SOURCE_DIR)/neutrino-hd2-plugins.org
	set -e; cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
		$(call apply_patches, $(NEUTRINO_HD2_PLUGINS_PATCHES))
	cp -ra $(SOURCE_DIR)/neutrino-hd2-plugins $(SOURCE_DIR)/neutrino-hd2-plugins.dev
	@touch $@

$(D)/neutrino-hd2-plugins.config.status: $(D)/bootstrap $(D)/neutrino-hd2
	rm -rf $(NP_OBJDIR)
	test -d $(NP_OBJDIR) || mkdir -p $(NP_OBJDIR)
	cd $(NP_OBJDIR); \
		$(SOURCE_DIR)/neutrino-hd2-plugins/autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/neutrino-hd2-plugins/configure $(SILENT_OPT) \
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
			CPPFLAGS="$(CPPFLAGS) -I$(driverdir) -I$(KERNEL_DIR)/include -I$(TARGET_DIR)/usr/include $(EXTRA_HDFLAGS)" \
			LDFLAGS="$(TARGET_LDFLAGS)"
	@touch $@

$(D)/neutrino-hd2-plugins.do_compile: $(D)/neutrino-hd2-plugins.config.status
	$(MAKE) -C $(NP_OBJDIR)
	@touch $@

$(D)/neutrino-hd2-plugins: neutrino-hd2-plugins.do_prepare neutrino-hd2-plugins.do_compile
	$(MAKE) -C $(NP_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

neutrino-hd2-plugins-clean:
	rm -f $(D)/neutrino-hd2-plugins
	rm -f $(D)/neutrino-hd2-plugins.do_*
	rm -f $(D)/neutrino-hd2-plugins.config.status
	cd $(NP_OBJDIR); \
		$(MAKE) -C $(NP_OBJDIR) clean

neutrino-hd2-plugins-distclean:
	rm -rf $(NP_OBJDIR)
	rm -f $(D)/neutrino-hd2-plugins
	rm -f $(D)/neutrino-hd2-plugins.do_*
	rm -f $(D)/neutrino-hd2-plugins.config.status
