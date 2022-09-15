#
# KERNEL
#
BRAND                  = octagon
KERNEL_VER             = 4.4.35
KERNEL_DATE            = 20181224
KERNEL_TYPE            = sf8008
KERNEL_SRC_VER         = $(KERNEL_VER)-$(KERNEL_DATE)
KERNEL_SRC             = $(BRAND)-linux-$(KERNEL_VER)-$(KERNEL_DATE).tar.gz
KERNEL_URL             = http://source.mynonpublic.com/$(BRAND)/
KERNEL_CONFIG          = $(KERNEL_TYPE)/defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-$(KERNEL_VER)
KERNEL_DTB_VER         = hi3798mv200.dtb

KERNEL_PATCHES = \
		armbox/$(KERNEL_TYPE)/0001-remote.patch \
		armbox/$(KERNEL_TYPE)/HauppaugeWinTV-dualHD.patch \
		armbox/$(KERNEL_TYPE)/dib7000-linux_4.4.179.patch \
		armbox/$(KERNEL_TYPE)/dvb-usb-linux_4.4.179.patch \
		armbox/$(KERNEL_TYPE)/0002-log2-give-up-on-gcc-constant-optimizations.patch \
		armbox/$(KERNEL_TYPE)/0003-dont-mark-register-as-const.patch \
		armbox/$(KERNEL_TYPE)/wifi-linux_4.4.183.patch \
		armbox/$(KERNEL_TYPE)/move-default-dialect-to-SMB3.patch \
		armbox/$(KERNEL_TYPE)/fix-dvbcore.patch \
		armbox/$(KERNEL_TYPE)/0005-xbox-one-tuner-4.4.patch \
		armbox/$(KERNEL_TYPE)/0006-dvb-media-tda18250-support-for-new-silicon-tuner.patch \
		armbox/$(KERNEL_TYPE)/0007-dvb-mn88472-staging.patch \
		armbox/$(KERNEL_TYPE)/mn88472_reset_stream_ID_reg_if_no_PLP_given.patch \
		armbox/$(KERNEL_TYPE)/4.4.35_fix-multiple-defs-yyloc.patch \
		armbox/$(KERNEL_TYPE)/af9035.patch

# others
#CAIRO_OPTS = \
#		--enable-egl \
#		--enable-glesv2

CUSTOM_RCS = $(SKEL_ROOT)/release/rcS_neutrino_$(KERNEL_TYPE)

# release target
neutrino-release-sf8008:
	install -m 0755 $(SKEL_ROOT)/release/halt_$(KERNEL_TYPE) $(RELEASE_DIR)/etc/init.d/halt
	install -m 0755 $(SKEL_ROOT)/release/showiframe_$(KERNEL_TYPE) $(RELEASE_DIR)/bin/showiframe
	install -m 0755 $(SKEL_ROOT)/release/libreader.sh_$(KERNEL_TYPE)  $(RELEASE_DIR)/usr/bin/libreader.sh
	install -d $(RELEASE_DIR)/var/spool/cron/crontabs
	install -m 0755 $(SKEL_ROOT)/release/root_$(KERNEL_TYPE)  $(RELEASE_DIR)/var/spool/cron/crontabs/root
	install -d $(RELEASE_DIR)/var/tuxbox/config
	touch $(RELEASE_DIR)/var/tuxbox/config/.crond
	install -m 0755 $(SKEL_ROOT)/release/suspend_$(KERNEL_TYPE)  $(RELEASE_DIR)/etc/init.d/suspend
	cp -f $(SKEL_ROOT)/release/fstab_sf8008 $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/uImage $(RELEASE_DIR)/tmp/
	install -m 0755 $(SKEL_ROOT)/etc/init.d/mmcblk-by-name $(RELEASE_DIR)/etc/init.d/mmcblk-by-name
	install -m 0755 $(SKEL_ROOT)/release/$(BRAND)-libreader $(RELEASE_DIR)/etc/init.d/
	cd $(RELEASE_DIR)/etc/rc.d/rc0.d; ln -sf ../../init.d/$(BRAND)-libreader ./S05$(BRAND)-libreader 
	cd $(RELEASE_DIR)/etc/rc.d/rc6.d; ln -sf ../../init.d/$(BRAND)-libreader ./S05$(BRAND)-libreader 

