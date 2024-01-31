#
# KERNEL
#
KERNEL_VER             = 4.4.35
KERNEL_DATE            = 20181224
KERNEL_TYPE            = sf8008m
KERNEL_SRC             = octagon-linux-$(KERNEL_VER)-$(KERNEL_DATE).tar.gz
KERNEL_URL             = http://source.mynonpublic.com/octagon
KERNEL_CONFIG          = defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-$(KERNEL_VER)
KERNEL_IMAGE           = uImage
KERNEL_DTB_VER         = hi3798mv200.dtb

KERNEL_PATCHES = \
		0002-log2-give-up-on-gcc-constant-optimizations.patch \
		0003-dont-mark-register-as-const.patch \
		0001-remote.patch \
		HauppaugeWinTV-dualHD.patch \
		dib7000-linux_4.4.179.patch \
		dvb-usb-linux_4.4.179.patch \
		wifi-linux_4.4.183.patch \
		move-default-dialect-to-SMB3.patch \
		fix-dvbcore.patch \
		0005-xbox-one-tuner-4.4.patch \
		0006-dvb-media-tda18250-support-for-new-silicon-tuner.patch \
		0007-dvb-mn88472-staging.patch \
		mn88472_reset_stream_ID_reg_if_no_PLP_given.patch \
		af9035.patch \
		4.4.35_fix-multiple-defs-yyloc.patch

#
# DRIVER
#

DRIVER_VER     = $(KERNEL_VER)
DRIVER_DATE    = 20220105
HILIB_DATE     = 20190917
LIBGLES_DATE   = 20180301
LIBREADER_DATE = 20200612
HIHALT_DATE    = 20200601
TNTFS_DATE     = 20200528

#
# IMAGE
#

MACHINE              = octagon
FLASH_PARTITONS_DATE = 20201218

# others
#CAIRO_OPTS = \
#		--enable-egl \
#		--enable-glesv2

CUSTOM_RCS =

# release target
neutrino-release-sf8008m:
	install -m 0755 $(MACHINE_FILES)/showiframe $(RELEASE_DIR)/bin
	install -m 0755 $(MACHINE_FILES)/libreader.sh  $(RELEASE_DIR)/usr/bin/libreader.sh
	install -d $(RELEASE_DIR)/var/spool/cron/crontabs
	install -m 0755 $(MACHINE_FILES)/root  $(RELEASE_DIR)/var/spool/cron/crontabs/root
	install -d $(RELEASE_DIR)/var/tuxbox/config
	touch $(RELEASE_DIR)/var/tuxbox/config/.crond
	install -m 0755 $(MACHINE_FILES)/suspend  $(RELEASE_DIR)/etc/init.d/suspend
	cp $(TARGET_DIR)/boot/uImage $(RELEASE_DIR)/tmp/
	install -m 0755 $(MACHINE_FILES)/libreader $(RELEASE_DIR)/etc/init.d/
	cd $(RELEASE_DIR)/etc/rc.d/rc0.d; ln -sf ../../init.d/libreader ./S05libreader
	cd $(RELEASE_DIR)/etc/rc.d/rc6.d; ln -sf ../../init.d/libreader ./S05libreader

