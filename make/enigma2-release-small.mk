#
# Build Dual Image
#
yaud-nmp-e2-tangos: yaud-none \
		neutrino-mp-tangos neutrino-mp-plugins enigma2-tangos enigma2-plugins release_neutrino release_enigma2_small
	$(TUXBOX_YAUD_CUSTOMIZE)

#
# release_common_utils
#
$(D)/release_enigma2_small:
	install -d $(RELEASE_DIR)/share && \
	install -d $(RELEASE_DIR)/var/etc/{enigma2,tuxbox,tuxtxt,opkg} && \
	install -d $(RELEASE_DIR)/usr/share/{enigma2,keymaps} && \
	install -d $(RELEASE_DIR)/var/opkg && \
	ln -s /usr/local/share/keymaps $(RELEASE_DIR)/usr/share/keymaps && \
	cp $(SKEL_ROOT)/etc/image-version $(RELEASE_DIR)/var/etc/ && \
	cp $(SKEL_ROOT)/root_enigma2/etc/tuxbox/satellites.xml $(RELEASE_DIR)/var/etc/tuxbox/ && \
	cp $(SKEL_ROOT)/root_enigma2/etc/tuxbox/cables.xml $(RELEASE_DIR)/var/etc/tuxbox/ && \
	cp $(SKEL_ROOT)/root_enigma2/etc/tuxbox/terrestrial.xml $(RELEASE_DIR)/var/etc/tuxbox/ && \
	cp $(SKEL_ROOT)/root_enigma2/etc/tuxtxt/tuxtxt2.conf $(RELEASE_DIR)/var/etc/tuxtxt/ && \
	cp -p $(TARGET_DIR)/usr/bin/opkg-cl $(RELEASE_DIR)/usr/bin/opkg && \
	cp -dp $(TARGET_DIR)/usr/bin/python* $(RELEASE_DIR)/usr/bin/ && \
	cp -p $(TARGET_DIR)/usr/sbin/ethtool $(RELEASE_DIR)/usr/sbin/ && \
	cp -p $(TARGET_DIR)/usr/sbin/livestreamersrv $(RELEASE_DIR)/usr/sbin/ && \
	cp -p $(TARGET_DIR)/usr/lib/libdvdnav.* $(RELEASE_DIR)/usr/lib/ && \
	cp -p $(TARGET_DIR)/usr/lib/libdvdread* $(RELEASE_DIR)/usr/lib/ && \
	cp -p $(TARGET_DIR)/usr/lib/libopkg* $(RELEASE_DIR)/usr/lib/

#
# lib usr/lib
#
	rm -rf $(RELEASE_DIR)/usr/lib/{engines,enigma2,gconv,ldscripts,libxslt-plugins,pkgconfig,python$(PYTHON_VERSION),sigc++-1.2,X11,lua}
	rm -f $(RELEASE_DIR)/usr/lib/*.{a,o,la}
	
#
# fonts
#
	cp -p $(TARGET_DIR)/usr/local/share/fonts/* $(RELEASE_DIR)/usr/share/fonts;
	cp -n $(SKEL_ROOT)/root_enigma2/usr/share/fonts/valis_enigma.ttf $(RELEASE_DIR)/usr/share/fonts;

#
# enigma2
#
	if [ -e $(TARGET_DIR)/usr/bin/enigma2 ]; then \
		cp -f $(TARGET_DIR)/usr/bin/enigma2 $(RELEASE_DIR)/usr/local/bin/enigma2; \
	fi

	if [ -e $(TARGET_DIR)/usr/local/bin/enigma2 ]; then \
		cp -f $(TARGET_DIR)/usr/local/bin/enigma2 $(RELEASE_DIR)/usr/local/bin/enigma2; \
	fi

	cp -a $(TARGET_DIR)/usr/local/share/enigma2/* $(RELEASE_DIR)/usr/share/enigma2
	cp $(SKEL_ROOT)/root_enigma2/etc/enigma2/* $(RELEASE_DIR)/var/etc/enigma2
	ln -sf /etc/timezone.xml $(RELEASE_DIR)/var/etc/tuxbox/timezone.xml

	install -d $(RELEASE_DIR)/usr/lib/enigma2
	cp -a $(TARGET_DIR)/usr/lib/enigma2/* $(RELEASE_DIR)/usr/lib/enigma2/

	if test -d $(TARGET_DIR)/usr/local/lib/enigma2; then \
		cp -a $(TARGET_DIR)/usr/local/lib/enigma2/* $(RELEASE_DIR)/usr/lib/enigma2; \
	fi

#
# python2.7
#
	if [ $(PYTHON_VERSION_MAJOR) == 2.7 ]; then \
		install -d $(RELEASE_DIR)/usr/include; \
		install -d $(RELEASE_DIR)$(PYTHON_INCLUDE_DIR); \
		cp $(TARGET_DIR)$(PYTHON_INCLUDE_DIR)/pyconfig.h $(RELEASE_DIR)$(PYTHON_INCLUDE_DIR); \
	fi

#
# tuxtxt
#
	if [ -e $(TARGET_DIR)/usr/bin/tuxtxt ]; then \
		cp -p $(TARGET_DIR)/usr/bin/tuxtxt $(RELEASE_DIR)/usr/bin/; \
	fi

#
# hotplug
#
	if [ -e $(TARGET_DIR)/usr/bin/hotplug_e2_helper ]; then \
		cp -dp $(TARGET_DIR)/usr/bin/hotplug_e2_helper $(RELEASE_DIR)/sbin/hotplug; \
		cp -dp $(TARGET_DIR)/usr/bin/bdpoll $(RELEASE_DIR)/sbin/; \
	else \
		cp -dp $(TARGET_DIR)/sbin/hotplug $(RELEASE_DIR)/sbin/; \
	fi

#
# delete unnecessary files
#
	rm -rf $(RELEASE_DIR)/lib/autofs
	rm -rf $(RELEASE_DIR)/usr/lib/m4-nofpu/
	rm -rf $(RELEASE_DIR)/lib/modules/$(KERNEL_VERSION)
	rm -rf $(RELEASE_DIR)/usr/lib/gcc
	rm -f $(RELEASE_DIR)/usr/lib/libc.so
	rm -rf $(RELEASE_DIR)/usr/lib/enigma2/python/Plugins/DemoPlugins
	rm -rf $(RELEASE_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/FrontprocessorUpgrade
	rm -rf $(RELEASE_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NFIFlash
	rm -rf $(RELEASE_DIR)/usr/lib/enigma2/python/Plugins/Extensions/FileManager
	rm -rf $(RELEASE_DIR)/usr/lib/enigma2/python/Plugins/Extensions/TuxboxPlugins
	install -d $(RELEASE_DIR)$(PYTHON_DIR)
	cp -a $(TARGET_DIR)$(PYTHON_DIR)/* $(RELEASE_DIR)$(PYTHON_DIR)/
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/{bsddb,compiler,curses,distutils,lib-old,lib-tk,plat-linux3,test}
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/ctypes/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/email/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/json/tests
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/lib2to3/tests
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/sqlite3/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/unittest/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/{test,conch,mail,names,news,words,flow,lore,pair,runner}
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/Cheetah/Tests
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/livestreamer_cli
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/lxml
	rm -f $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/libxml2mod.so
	rm -f $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/libxsltmod.so
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/OpenSSL/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/setuptools
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/zope/interface/tests
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/application/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/conch/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/internet/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/lore/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/mail/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/manhole/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/names/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/news/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/pair/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/persisted/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/protocols/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/python/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/runner/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/scripts/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/trial/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/web/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/twisted/words/test
	rm -rf $(RELEASE_DIR)$(PYTHON_DIR)/site-packages/*-py$(PYTHON_VERSION_MAJOR).egg-info

#
# Dont remove pyo files, remove pyc instead
#
	find $(RELEASE_DIR)/usr/lib/enigma2/ -name '*.pyc' -exec rm -f {} \;
#	find $(RELEASE_DIR)/usr/lib/enigma2/ -not -name 'mytest.py' -name '*.py' -exec rm -f {} \;
	find $(RELEASE_DIR)/usr/lib/enigma2/ -name '*.a' -exec rm -f {} \;
	find $(RELEASE_DIR)/usr/lib/enigma2/ -name '*.o' -exec rm -f {} \;
	find $(RELEASE_DIR)/usr/lib/enigma2/ -name '*.la' -exec rm -f {} \;

#
	find $(RELEASE_DIR)$(PYTHON_DIR)/ -name '*.pyc' -exec rm -f {} \;
#	find $(RELEASE_DIR)$(PYTHON_DIR)/ -name '*.py' -exec rm -f {} \;
	find $(RELEASE_DIR)$(PYTHON_DIR)/ -name '*.a' -exec rm -f {} \;
	find $(RELEASE_DIR)$(PYTHON_DIR)/ -name '*.c' -exec rm -f {} \;
	find $(RELEASE_DIR)$(PYTHON_DIR)/ -name '*.pyx' -exec rm -f {} \;
	find $(RELEASE_DIR)$(PYTHON_DIR)/ -name '*.o' -exec rm -f {} \;
	find $(RELEASE_DIR)$(PYTHON_DIR)/ -name '*.la' -exec rm -f {} \;

#
# FOR YOUR OWN CHANGES use these folder in cdk/own_build/enigma2
#
#	default for all receiver
	find $(OWN_BUILD)/enigma2/ -mindepth 1 -maxdepth 1 -exec cp -at$(RELEASE_DIR)/ -- {} +
#	receiver specific (only if directory exist)
	[ -d "$(OWN_BUILD)/enigma2.$(BOXTYPE)" ] && find $(OWN_BUILD)/enigma2.$(BOXTYPE)/ -mindepth 1 -maxdepth 1 -exec cp -at$(RELEASE_DIR)/ -- {} + || true
	rm -f $(RELEASE_DIR)/for_your_own_changes
#
# sh4-linux-strip all
#
	find $(RELEASE_DIR)/ -name '*' -exec sh4-linux-strip --strip-unneeded {} &>/dev/null \;

	touch $@
