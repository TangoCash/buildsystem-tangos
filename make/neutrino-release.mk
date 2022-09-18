#
# auxiliary targets for model-specific builds
#

python-iptv-install:
	install -d $(RELEASE_DIR)/usr/bin; \
	install -d $(RELEASE_DIR)/usr/include; \
	install -d $(RELEASE_DIR)/usr/lib; \
	install -d $(RELEASE_DIR)/$(PYTHON_INCLUDE_DIR); \
	install -d $(RELEASE_DIR)/$(PYTHON_DIR); \
	cp $(TARGET_DIR)/$(PYTHON_INCLUDE_DIR)/pyconfig.h $(RELEASE_DIR)/$(PYTHON_INCLUDE_DIR); \
	cp -P $(TARGET_LIB_DIR)/libpython* $(RELEASE_DIR)/usr/lib; \
	cp -P $(TARGET_DIR)/usr/bin/python* $(RELEASE_DIR)/usr/bin; \
	cp -a $(TARGET_DIR)/$(PYTHON_DIR)/* $(RELEASE_DIR)/$(PYTHON_DIR)/; \
	cp -af $(TARGET_SHARE_DIR)/E2emulator $(RELEASE_DIR)/usr/share/; \
	ln -sf /usr/share/E2emulator/Plugins/Extensions/IPTVPlayer/cmdlineIPTV.sh $(RELEASE_DIR)/usr/bin/cmdlineIPTV; \
	rm -f $(RELEASE_DIR)/usr/bin/{cftp,ckeygen,easy_install*,mailmail,pyhtmlizer,tkconch,trial,twist,twistd}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/{bsddb,compiler,curses,distutils,email,ensurepip,hotshot,idlelib,lib2to3}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/{lib-old,lib-tk,multiprocessing,plat-linux2,pydoc_data,sqlite3,unittest,wsgiref}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/lib-dynload/{_codecs_*.so,_curses*.so,_csv.so,_multi*.so}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/lib-dynload/{audioop.so,cmath.so,future_builtins.so,mmap.so,strop.so}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/setuptools
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/{application,conch,cred,enterprise,flow,lore,mail,names,news,pair,persisted}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/{plugins,positioning,runner,scripts,spread,tap,_threads,trial,web,words}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/python/_pydoctortemplates
	find $(RELEASE_DIR)/$(PYTHON_DIR)/ $(RELEASE_DIR)/usr/share/E2emulator/ \
		\( -name '*.a' \
		-o -name '*.c' \
		-o -name '*.doc' \
		-o -name '*.egg-info' \
		-o -name '*.la' \
		-o -name '*.o' \
		-o -name '*.pyc' \
		-o -name '*.pyx' \
		-o -name '*.txt' \
		-o -name 'test' \
		-o -name 'tests' \) \
		-print0 | xargs --no-run-if-empty -0 rm -rf
ifeq ($(OPTIMIZATIONS), size)
	find $(RELEASE_DIR)/$(PYTHON_DIR)/ -name '*.py' -exec rm -f {} \;
	find $(RELEASE_DIR)/usr/share/E2emulator/ -name '*.py' -exec rm -f {} \;
endif

python-install: $(D)/python
	install -d $(RELEASE_DIR)/usr/bin; \
	install -d $(RELEASE_DIR)/usr/include; \
	install -d $(RELEASE_DIR)/usr/lib; \
	install -d $(RELEASE_DIR)/$(PYTHON_INCLUDE_DIR); \
	install -d $(RELEASE_DIR)/$(PYTHON_DIR); \
	cp $(TARGET_DIR)/$(PYTHON_INCLUDE_DIR)/pyconfig.h $(RELEASE_DIR)/$(PYTHON_INCLUDE_DIR); \
	cp -P $(TARGET_LIB_DIR)/libpython* $(RELEASE_DIR)/usr/lib; \
	cp -P $(TARGET_DIR)/usr/bin/python* $(RELEASE_DIR)/usr/bin; \
	cp -a $(TARGET_DIR)/$(PYTHON_DIR)/* $(RELEASE_DIR)/$(PYTHON_DIR)/; \
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/{bsddb,compiler,curses,distutils,lib-old,lib-tk,plat-linux3,test}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/{test,conch,mail,names,news,words,flow,lore,pair,runner}
	#rm -f $(RELEASE_DIR)/usr/bin/{cftp,ckeygen,easy_install*,mailmail,pyhtmlizer,tkconch,trial,twist,twistd}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/livestreamer_cli
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/lxml
	rm -f  $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/libxml2mod.so
	rm -f  $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/libxsltmod.so
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/setuptools
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/*-py$(PYTHON_VERSION).egg-info
	find $(RELEASE_DIR)/$(PYTHON_DIR)/ \
		\( -name '*.a' \
		-o -name '*.c' \
		-o -name '*.doc' \
		-o -name '*.egg-info' \
		-o -name '*.la' \
		-o -name '*.o' \
		-o -name '*.pyc' \
		-o -name '*.pyx' \
		-o -name '*.txt' \
		-o -name 'test' \
		-o -name 'tests' \) \
		-print0 | xargs --no-run-if-empty -0 rm -rf
ifeq ($(OPTIMIZATIONS), size)
	find $(RELEASE_DIR)/$(PYTHON_DIR)/ -name '*.py' -exec rm -f {} \;
endif

#
# neutrino-release-base
#
# the following target creates the common file base
neutrino-release-base:
	rm -rf $(RELEASE_DIR) || true
	rm -rf $(RELEASE_DIR_CLEANUP) || true
	install -d $(RELEASE_DIR)
	install -d $(RELEASE_DIR)/{autofs,bin,boot,dev,dev.static,etc,lib,media,mnt,proc,ram,root,sbin,storage,sys,tmp,usr,var}
	install -d $(RELEASE_DIR)/etc/{init.d,network,mdev,ssl}
	install -d $(RELEASE_DIR)/etc/network/if-{post-{up,down},pre-{up,down},up,down}.d
	install -d $(RELEASE_DIR)/lib/{modules,udev,firmware}
	install -d $(RELEASE_DIR)/usr/{bin,lib,sbin,share}
	if [ $(BOXARCH) = "aarch64" ]; then \
		cd ${RELEASE_DIR}; ln -sf lib lib64; \
		cd ${RELEASE_DIR}/usr; ln -sf lib lib64; \
	fi
	install -d $(RELEASE_DIR)/usr/share/{fonts,tuxbox,udhcpc,zoneinfo,lua}
	install -d $(RELEASE_DIR)/usr/share/tuxbox/neutrino/{icons,luaplugins,plugins}
	install -d $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/logo
	install -d $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/logo/events
	install -d $(RELEASE_DIR)/usr/share/lua/5.2
	install -d $(RELEASE_DIR)/var/{bin,emu,etc,epg,httpd,keys,lib,net,tuxbox,update}
	ln -sf /mnt $(RELEASE_DIR)/var/mnt
	ln -sf /var/epg $(RELEASE_DIR)/var/net/epg
	install -d $(RELEASE_DIR)/var/lib/{opkg,nfs,modules}
	install -d $(RELEASE_DIR)/var/tuxbox/{config,control,fonts,locale,plugins,themes}
	install -d $(RELEASE_DIR)/var/tuxbox/{webtv,webradio}
	install -d $(RELEASE_DIR)/var/tuxbox/config/zapit
	mkdir -p $(RELEASE_DIR)/etc/rc.d/rc0.d
	ln -s ../init.d/sendsigs $(RELEASE_DIR)/etc/rc.d/rc0.d/S20sendsigs
	ln -s ../init.d/umountfs $(RELEASE_DIR)/etc/rc.d/rc0.d/S40umountfs
	ln -s ../init.d/halt $(RELEASE_DIR)/etc/rc.d/rc0.d/S90halt
	mkdir -p $(RELEASE_DIR)/etc/rc.d/rc6.d
	ln -s ../init.d/sendsigs $(RELEASE_DIR)/etc/rc.d/rc6.d/S20sendsigs
	ln -s ../init.d/umountfs $(RELEASE_DIR)/etc/rc.d/rc6.d/S40umountfs
	ln -s ../init.d/reboot $(RELEASE_DIR)/etc/rc.d/rc6.d/S90reboot
	ln -sf /usr/share/tuxbox/neutrino/icons/logo $(RELEASE_DIR)/logos
	ln -sf /usr/share/tuxbox/neutrino/icons/logo $(RELEASE_DIR)/var/logos
	ln -sf /usr/share/tuxbox/neutrino/icons/logo $(RELEASE_DIR)/var/httpd/logos
	ln -sf /usr/share $(RELEASE_DIR)/share
	touch $(RELEASE_DIR)/var/etc/.firstboot
	cp -a $(TARGET_DIR)/bin/* $(RELEASE_DIR)/bin/
	cp -a $(TARGET_DIR)/usr/bin/* $(RELEASE_DIR)/usr/bin/
	cp -a $(TARGET_DIR)/sbin/* $(RELEASE_DIR)/sbin/
	cp -a $(TARGET_DIR)/usr/sbin/* $(RELEASE_DIR)/usr/sbin/
	cp -dp $(TARGET_DIR)/.version $(RELEASE_DIR)/
	ln -sf /.version $(RELEASE_DIR)/var/etc/.version
	ln -sf /.version $(RELEASE_DIR)/usr/.version
	ln -sf /proc/mounts $(RELEASE_DIR)/etc/mtab
ifeq ($(LAYOUT), multi)
	mv $(RELEASE_DIR)/sbin/init $(RELEASE_DIR)/sbin/init.sysvinit
	install -m 0755 $(SKEL_ROOT)/sbin/init $(RELEASE_DIR)/sbin/
endif
	cp -aR $(SKEL_ROOT)/etc/mdev/* $(RELEASE_DIR)/etc/mdev/
	cp -aR $(SKEL_ROOT)/etc/{inetd.conf,irexec.keys,issue.net,passwd} $(RELEASE_DIR)/etc/
	cp -aR $(SKEL_ROOT)/etc/network/* $(RELEASE_DIR)/etc/network/
	cp -aR $(SKEL_ROOT)/etc/mdev_$(BOXARCH).conf $(RELEASE_DIR)/etc/mdev.conf
	cp -aR $(SKEL_ROOT)/usr/share/udhcpc/* $(RELEASE_DIR)/usr/share/udhcpc/
	cp -aR $(SKEL_ROOT)/usr/share/zoneinfo/* $(RELEASE_DIR)/usr/share/zoneinfo/
	install -m 0755 $(SKEL_ROOT)/bin/autologin $(RELEASE_DIR)/bin/
	install -m 0755 $(SKEL_ROOT)/bin/vdstandby $(RELEASE_DIR)/bin/
	install -m 0755 $(SKEL_ROOT)/etc/init.d/check_partitions $(TARGET_DIR)/etc/init.d/
	install -m 0755 $(SKEL_ROOT)/etc/init.d/mount_before $(TARGET_DIR)/etc/init.d/
	install -m 0755 $(SKEL_ROOT)/etc/init.d/mmcblk-by-name $(RELEASE_DIR)/etc/init.d/
	install -m 0755 $(SKEL_ROOT)/etc/init.d/before_gui $(RELEASE_DIR)/etc/init.d/
	install -m 0755 $(TARGET_DIR)/etc/init.d/* $(RELEASE_DIR)/etc/init.d/
	install -m 0644 $(MACHINE_COMMON_DIR)/bootlogo.m2v $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/bootlogo.m2v
	cp -aR $(TARGET_DIR)/etc/* $(RELEASE_DIR)/etc/
	echo "$(BOXTYPE)" > $(RELEASE_DIR)/etc/hostname
	ln -sf ../../bin/busybox $(RELEASE_DIR)/usr/bin/ether-wake
	ln -sf ../../bin/showiframe $(RELEASE_DIR)/usr/bin/showiframe
	[ ! -z "$(CUSTOM_RCS)" ] && install -m 0755 $(CUSTOM_RCS) $(RELEASE_DIR)/etc/init.d/rcS || true
#
#
#
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/usbserial.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/usbserial.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ftdi_sio.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ftdi_sio.ko $(RELEASE_DIR)/lib/modules/ftdi_sio.ko || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/pl2303.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/pl2303.ko $(RELEASE_DIR)/lib/modules/ || true
#
# wlan
#
ifeq ($(IMAGE), neutrino-wifi)
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8188eu/r8188eu.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8188eu/r8188eu.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/wireless/cfg80211.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/wireless/cfg80211.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/rfkill/rfkill.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/rfkill/rfkill.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/mac80211/mac80211.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/mac80211/mac80211.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtlwifi.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtlwifi.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl_usb.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl_usb.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl8192c/rtl8192c-common.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl8192c/rtl8192c-common.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/rtl8192cu.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/rtl8192cu.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8712/r8712u.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8712/r8712u.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/mediatek/mt7601u/mt7601u.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/mediatek/mt7601u/mt7601u.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8712/r8712u.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8712/r8712u.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8192u/r8192u_usb.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8192u/r8192u_usb.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.ko $(RELEASE_DIR)/lib/modules/ || true
endif
#
#
################################################################################
#
# wlan firmware
#
ifeq ($(IMAGE), neutrino-wifi)
	install -d $(RELEASE_DIR)/etc/Wireless
	cp -aR $(SKEL_ROOT)/firmware/Wireless/* $(RELEASE_DIR)/etc/Wireless/
	cp -aR $(SKEL_ROOT)/firmware/rtlwifi $(RELEASE_DIR)/lib/firmware/
	cp -aR $(SKEL_ROOT)/firmware/*.bin $(RELEASE_DIR)/lib/firmware/
endif
#
# modules.available // modules.default
#
	cp -aR $(MACHINE_COMMON_DIR)/modules.available_$(BOXARCH) $(RELEASE_DIR)/etc/modules.available
	if [ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/modules.default ]; then \
		cp -aR $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/modules.default $(RELEASE_DIR)/etc/modules.default; \
	fi;
#
# lib usr/lib
#
	cp -R $(TARGET_DIR)/lib/* $(RELEASE_DIR)/lib/
	rm -f $(RELEASE_DIR)/lib/*.{a,o,la}
	chmod 755 $(RELEASE_DIR)/lib/*
	ln -s /var/tuxbox/plugins/libfx2.so $(RELEASE_DIR)/lib/libfx2.so
	cp -R $(TARGET_LIB_DIR)/* $(RELEASE_DIR)/usr/lib/
	rm -rf $(RELEASE_DIR)/usr/lib/{engines,gconv,libxslt-plugins,pkgconfig,python$(PYTHON_VER),sigc++-2.0}
	rm -f $(RELEASE_DIR)/usr/lib/*.{a,o,la}
	chmod 755 $(RELEASE_DIR)/usr/lib/*
#
# fonts
#
	if [ -e $(TARGET_SHARE_DIR)/fonts/ubuntu-l-webfont.ttf ]; then \
		cp -aR $(TARGET_SHARE_DIR)/fonts $(RELEASE_DIR)/usr/share/; \
	else \
		if [ -e $(TARGET_SHARE_DIR)/fonts/neutrino.ttf ]; then \
			cp -aR $(TARGET_SHARE_DIR)/fonts/neutrino.ttf $(RELEASE_DIR)/usr/share/fonts; \
			ln -s /usr/share/fonts/neutrino.ttf $(RELEASE_DIR)/usr/share/fonts/pakenham.ttf; \
		fi; \
		if [ -e $(TARGET_SHARE_DIR)/fonts/micron.ttf ]; then \
			cp -aR $(TARGET_SHARE_DIR)/fonts/micron.ttf $(RELEASE_DIR)/usr/share/fonts; \
		fi; \
		if [ -e $(TARGET_SHARE_DIR)/fonts/tuxtxt.ttf ]; then \
			cp -aR $(TARGET_SHARE_DIR)/fonts/tuxtxt.ttf $(RELEASE_DIR)/usr/share/fonts; \
			ln -s /usr/share/fonts/tuxtxt.ttf $(RELEASE_DIR)/usr/share/fonts/shell.ttf; \
		fi; \
	fi
#
# neutrino
#
	if [ -e $(TARGET_DIR)/usr/bin/install.sh ]; then \
		ln -s /usr/bin/install.sh $(RELEASE_DIR)/bin/; \
	fi
	if [ -e $(TARGET_DIR)/usr/bin/backup.sh ]; then \
		ln -s /usr/bin/backup.sh $(RELEASE_DIR)/bin/; \
	fi
	if [ -e $(TARGET_DIR)/usr/bin/restore.sh ]; then \
		ln -s /usr/bin/restore.sh $(RELEASE_DIR)/bin/; \
	fi

#
# channellist / tuxtxt
#
	cp -aR $(TARGET_DIR)/var/tuxbox/config/* $(RELEASE_DIR)/var/tuxbox/config
#
# iso-codes
#
	[ -e $(TARGET_SHARE_DIR)/iso-codes ] && cp -aR $(TARGET_SHARE_DIR)/iso-codes $(RELEASE_DIR)/usr/share/ || true
	[ -e $(TARGET_SHARE_DIR)/tuxbox/iso-codes ] && cp -aR $(TARGET_SHARE_DIR)/tuxbox/iso-codes $(RELEASE_DIR)/usr/share/tuxbox/ || true
#
# httpd/icons/locale/themes
#
	cp -aR $(TARGET_SHARE_DIR)/tuxbox/neutrino/* $(RELEASE_DIR)/usr/share/tuxbox/neutrino
ifeq ($(EXTERNAL_LCD), $(filter $(EXTERNAL_LCD), lcd4linux both))
	cp -aR $(TARGET_SHARE_DIR)/lcd $(RELEASE_DIR)/usr/share
	cp -aR $(TARGET_DIR)/var/lcd $(RELEASE_DIR)/var
endif
#
# e2-multiboot
#
	if [ -e $(TARGET_DIR)/var/lib/opkg/status ]; then \
		cp -af $(TARGET_DIR)/etc/image-version $(RELEASE_DIR)/etc; \
		cp -af $(TARGET_DIR)/etc/issue $(RELEASE_DIR)/etc; \
		cp -af $(TARGET_DIR)/usr/bin/enigma2 $(RELEASE_DIR)/usr/bin; \
		cp -af $(TARGET_DIR)/var/lib/opkg/status $(RELEASE_DIR)/var/lib/opkg; \
	fi
#
# alsa
#
	if [ -e $(TARGET_SHARE_DIR)/alsa ]; then \
		mkdir -p $(RELEASE_DIR)/usr/share/alsa/; \
		mkdir $(RELEASE_DIR)/usr/share/alsa/cards/; \
		mkdir $(RELEASE_DIR)/usr/share/alsa/pcm/; \
		cp -dp $(TARGET_SHARE_DIR)/alsa/alsa.conf $(RELEASE_DIR)/usr/share/alsa/alsa.conf; \
		cp $(TARGET_SHARE_DIR)/alsa/cards/aliases.conf $(RELEASE_DIR)/usr/share/alsa/cards/; \
		cp $(TARGET_SHARE_DIR)/alsa/pcm/default.conf $(RELEASE_DIR)/usr/share/alsa/pcm/; \
		cp $(TARGET_SHARE_DIR)/alsa/pcm/dmix.conf $(RELEASE_DIR)/usr/share/alsa/pcm/; \
	fi
#
# gdb
#
	if [ -e $(TARGET_DIR)/usr/bin/gdb ]; then \
		cp -aR $(TARGET_SHARE_DIR)/gdb $(RELEASE_DIR)/usr/share; \
	fi
#
# tvheadend
#
	if [ -e $(TARGET_DIR)/usr/bin/tvheadend ]; then \
		cp -aR $(TARGET_SHARE_DIR)/tvheadend $(RELEASE_DIR)/usr/share; \
	fi
#
# xupnpd
#
	if [ -e $(TARGET_DIR)/usr/bin/xupnpd ]; then \
		cp -aR $(TARGET_SHARE_DIR)/xupnpd $(RELEASE_DIR)/usr/share; \
		mkdir -p $(RELEASE_DIR)/usr/share/xupnpd/playlists; \
	fi
#
# mc
#
	if [ -e $(TARGET_DIR)/usr/bin/mc ]; then \
		cp -aR $(TARGET_SHARE_DIR)/mc $(RELEASE_DIR)/usr/share/; \
		cp -af $(TARGET_DIR)/usr/libexec $(RELEASE_DIR)/usr/; \
	fi
#
# lua
#
	if [ -d $(TARGET_SHARE_DIR)/lua ]; then \
		cp -aR $(TARGET_SHARE_DIR)/lua $(RELEASE_DIR)/usr/share; \
	fi
#
# astra-sm
#
	if [ -d $(TARGET_DIR)/usr/bin/astra ]; then \
		cp -aR $(TARGET_SHARE_DIR)/astra $(RELEASE_DIR)/usr/share; \
	fi
#
# plugins
#
	if [ -d $(TARGET_DIR)/var/tuxbox/plugins ]; then \
		cp -af $(TARGET_DIR)/var/tuxbox/plugins $(RELEASE_DIR)/var/tuxbox/; \
	fi
	if [ -d $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins ]; then \
		cp -af $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins $(RELEASE_DIR)/usr/share/tuxbox/neutrino/; \
	fi
	if [ -e $(RELEASE_DIR)/var/tuxbox/plugins/tuxwetter.so ]; then \
		cp -rf $(TARGET_DIR)/var/tuxbox/config/tuxwetter $(RELEASE_DIR)/var/tuxbox/config; \
	fi
	if [ -e $(RELEASE_DIR)/var/tuxbox/plugins/sokoban.so ]; then \
		cp -rf $(TARGET_SHARE_DIR)/tuxbox/sokoban $(RELEASE_DIR)/var/tuxbox/plugins; \
		ln -s /var/tuxbox/plugins/sokoban $(RELEASE_DIR)/usr/share/tuxbox/sokoban; \
	fi
	if [ -d $(TARGET_SHARE_DIR)/E2emulator ]; then \
		make python-iptv-install; \
	fi

	if [ -e $(RELEASE_DIR)/var/tuxbox/plugins/tuxcom.so ]; then \
		mv $(RELEASE_DIR)/var/tuxbox/plugins/tuxcom* $(RELEASE_DIR)/usr/share/tuxbox/neutrino/plugins; \
	fi

#
# webtv/webradio
#
	if [ -d $(TARGET_DIR)/var/tuxbox/webtv ]; then \
		cp -af $(TARGET_DIR)/var/tuxbox/webtv $(RELEASE_DIR)/var/tuxbox/; \
	fi
	if [ -d $(TARGET_DIR)/var/tuxbox/webradio ]; then \
		cp -af $(TARGET_DIR)/var/tuxbox/webradio $(RELEASE_DIR)/var/tuxbox/; \
	fi

#
# shairport
#
	if [ -e $(TARGET_DIR)/usr/bin/shairport ]; then \
		cp -f $(TARGET_DIR)/usr/bin/shairport $(RELEASE_DIR)/usr/bin; \
		cp -f $(TARGET_DIR)/usr/bin/mDNSPublish $(RELEASE_DIR)/usr/bin; \
		cp -f $(TARGET_DIR)/usr/bin/mDNSResponder $(RELEASE_DIR)/usr/bin; \
		cp -f $(SKEL_ROOT)/etc/init.d/shairport $(RELEASE_DIR)/etc/init.d/shairport; \
		chmod 755 $(RELEASE_DIR)/etc/init.d/shairport; \
		cp -f $(TARGET_LIB_DIR)/libhowl.so* $(RELEASE_DIR)/usr/lib; \
		cp -f $(TARGET_LIB_DIR)/libmDNSResponder.so* $(RELEASE_DIR)/usr/lib; \
	fi
#
# mupen64
#
	if [ -e $(TARGET_DIR)/usr/bin/mupen64plus ]; then \
		cp -f $(TARGET_DIR)/usr/bin/mupen64plus $(RELEASE_DIR)/usr/bin; \
		cp -rf $(TARGET_SHARE_DIR)/mupen64plus $(RELEASE_DIR)/usr/share; \
		cp -f $(TARGET_LIB_DIR)/libmupen64plus.so* $(RELEASE_DIR)/usr/lib; \
		cp -f $(TARGET_LIB_DIR)/libSDL2* $(RELEASE_DIR)/usr/lib; \
	fi
#
# Neutrino HD2 Workaround Build in Player
#
	if [ -e $(TARGET_DIR)/usr/bin/eplayer3 ]; then \
		cp -f $(TARGET_DIR)/usr/bin/eplayer3 $(RELEASE_DIR)/bin/; \
		cp -f $(TARGET_DIR)/usr/bin/meta $(RELEASE_DIR)/bin/; \
	fi
#
# delete unnecessary files
#
	rm -f $(RELEASE_DIR)/usr/lib/lua/5.2/*.la
	rm -rf $(RELEASE_DIR)/lib/autofs
	rm -f $(RELEASE_DIR)/lib/libSegFault*
	rm -f $(RELEASE_DIR)/lib/libstdc++.*-gdb.py
	rm -f $(RELEASE_DIR)/lib/libthread_db*
	rm -f $(RELEASE_DIR)/lib/libanl*
	rm -rf $(RELEASE_DIR)/lib/modules/$(KERNEL_VER)
	rm -rf $(RELEASE_DIR)/usr/lib/alsa
	rm -rf $(RELEASE_DIR)/usr/lib/glib-2.0
	rm -rf $(RELEASE_DIR)/usr/lib/cmake
	rm -f $(RELEASE_DIR)/usr/lib/*.py
	rm -f $(RELEASE_DIR)/usr/lib/libc.so
	rm -f $(RELEASE_DIR)/usr/lib/xml2Conf.sh
	rm -f $(RELEASE_DIR)/usr/lib/libfontconfig*
	rm -f $(RELEASE_DIR)/usr/lib/libdvdcss*
	rm -f $(RELEASE_DIR)/usr/lib/libdvdnav*
	rm -f $(RELEASE_DIR)/usr/lib/libdvdread*
	rm -f $(RELEASE_DIR)/usr/lib/libthread_db*
	rm -f $(RELEASE_DIR)/usr/lib/libanl*
	rm -f $(RELEASE_DIR)/usr/lib/libopkg*
	rm -f $(RELEASE_DIR)/bin/gitVCInfo
	rm -f $(RELEASE_DIR)/bin/evtest
	rm -f $(RELEASE_DIR)/bin/meta
	rm -f $(RELEASE_DIR)/bin/streamproxy
	rm -f $(RELEASE_DIR)/bin/libstb-hal-test
	rm -f $(RELEASE_DIR)/sbin/ldconfig
	rm -f $(RELEASE_DIR)/usr/bin/pic2m2v
	rm -f $(RELEASE_DIR)/usr/bin/{gdbus-codegen,glib-*,gtester-report}
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm aarch64))
	rm -rf $(RELEASE_DIR)/dev.static
	rm -rf $(RELEASE_DIR)/ram
	rm -rf $(RELEASE_DIR)/root
endif
#
# The main target depends on the model.
# IMPORTANT: it is assumed that only one variable is set. Otherwise the target name won't be resolved.
#
$(D)/neutrino-release: neutrino-release-base neutrino-release-$(BOXTYPE)
	$(TUXBOX_CUSTOMIZE)
#
# FOR YOUR OWN CHANGES use these folder in own_build/neutrino-hd
#
#	default for all receiver
	find $(OWN_BUILD)/neutrino-hd/ -mindepth 1 -maxdepth 1 -exec cp -at$(RELEASE_DIR)/ -- {} +
#	receiver specific (only if directory exist)
	[ -d "$(OWN_BUILD)/neutrino-hd.$(BOXTYPE)" ] && find $(OWN_BUILD)/neutrino-hd.$(BOXTYPE)/ -mindepth 1 -maxdepth 1 -exec cp -at$(RELEASE_DIR)/ -- {} + || true
#	receiver/layout specific (only if directory exist)
	[ -d "$(OWN_BUILD)/neutrino-hd.$(BOXTYPE).$(LAYOUT)" ] && find $(OWN_BUILD)/neutrino-hd.$(BOXTYPE).$(LAYOUT)/ -mindepth 1 -maxdepth 1 -exec cp -at$(RELEASE_DIR)/ -- {} + || true
#	append boxmodel
	echo $(BOXTYPE) > $(RELEASE_DIR)/etc/model

#
#	moving /etc to /var/etc and create symlink
#
	cp -dpfr $(RELEASE_DIR)/etc $(RELEASE_DIR)/var
	rm -fr $(RELEASE_DIR)/etc
	ln -sf var/etc $(RELEASE_DIR)/etc
#
#	create some needed symlinks
#
	ln -s /tmp $(RELEASE_DIR)/lib/init
	ln -s /tmp $(RELEASE_DIR)/var/lib/urandom
	ln -s /tmp $(RELEASE_DIR)/var/lock
	ln -s /tmp $(RELEASE_DIR)/var/log
	ln -s /tmp $(RELEASE_DIR)/var/run
	ln -s /tmp $(RELEASE_DIR)/var/tmp
#
#	cleanup and optimize
#
	find $(RELEASE_DIR)/lib $(RELEASE_DIR)/usr/lib/ \
		\( -name '*.a' \
		-o -name '*.la' \) \
		-print0 | xargs --no-run-if-empty -0 rm -f
ifneq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), kerneldebug debug normal))
	find $(RELEASE_DIR)/ -name '*' -exec $(TARGET)-strip --strip-unneeded {} &>/dev/null \;
endif
	@$(call draw_line,);
	@$(call draw_line,Build of neutrino release for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);
	@touch $@
#
# neutrino-release-clean
#
neutrino-release-clean:
	rm -f $(D)/neutrino-release
