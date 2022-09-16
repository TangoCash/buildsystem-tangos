#
# driver
#
DRIVER_VER = 4.4.35
DRIVER_DATE = 20201118
DRIVER_SRC = $(KERNEL_TYPE)-drivers-$(DRIVER_VER)-$(DRIVER_DATE).zip

HICHIPSET = 3798mv200
PLAYERLIB_DATE = 20200625
PLAYERLIB_SRC = zgemma-libs-$(HICHIPSET)-$(PLAYERLIB_DATE).zip

TNTFS_DATE = 20200528
TNTFS_SRC = $(HICHIPSET)-tntfs-$(TNTFS_DATE).zip

LIBMALI_DATE = 20211026
LIBMALI_SRC = zgemma-mali-$(HICHIPSET)-$(LIBMALI_DATE).zip

MALI_MODULE_VER = DX910-SW-99002-r7p0-00rel0
MALI_MODULE_SRC = $(MALI_MODULE_VER).tgz
MALI_MODULE_PATCH = 0001-hi3798mv200-support.patch

WIFI_DIR = RTL8192FU-main
WIFI_SRC = main.zip
WIFI = RTL8192EU.zip

#LIBGLES_HEADERS = hd-v3ddriver-headers.tar.gz

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/zgemma/$(DRIVER_SRC)

$(ARCHIVE)/$(PLAYERLIB_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/zgemma/$(PLAYERLIB_SRC)

$(ARCHIVE)/$(LIBMALI_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/zgemma/$(LIBMALI_SRC)

$(ARCHIVE)/$(LIBGLES_HEADERS):
	$(DOWNLOAD) http://downloads.mutant-digital.net/v3ddriver/$(LIBGLES_HEADERS)

$(ARCHIVE)/$(TNTFS_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/tntfs/$(TNTFS_SRC)

$(ARCHIVE)/$(WIFI_SRC):
	$(DOWNLOAD) https://github.com/TangoCash/RTL8192FU/archive/refs/heads/$(WIFI_SRC) -O $(ARCHIVE)/$(WIFI)

$(ARCHIVE)/$(MALI_MODULE_SRC):
	$(DOWNLOAD) https://developer.arm.com/-/media/Files/downloads/mali-drivers/kernel/mali-utgard-gpu/$(MALI_MODULE_SRC);name=driver

driver-clean:
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/$(MACHINE)*
	rm -f $(TARGET_LIB_DIR)/hisilicon/*

driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	unzip -o $(ARCHIVE)/$(DRIVER_SRC) -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	$(MAKE) install-tntfs
	$(MAKE) install-wifi
	install -m 0755 $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/turnoff_power $(TARGET_DIR)/bin
	ls $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra | sed s/.ko//g > $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/modules.default
#	$(MAKE) install-hisiplayer-preq
#	$(MAKE) install-hisiplayer-libs
#	$(MAKE) install-libmali
#	$(MAKE) install-v3ddriver
#	$(MAKE) install-v3ddriver-header
#	$(MAKE) mali-gpu-modul
	$(TOUCH)

$(D)/install-hisiplayer-preq: $(D)/zlib $(D)/libpng $(D)/freetype $(D)/libcurl $(D)/libxml2 $(D)/libjpeg_turbo2 $(D)/harfbuzz

$(D)/install-v3ddriver: $(ARCHIVE)/$(LIBGLES_SRC)
	install -d $(TARGET_LIB_DIR)
	unzip -o $(ARCHIVE)/$(LIBGLES_SRC) -d $(TARGET_LIB_DIR)
	#patchelf --set-soname libv3ddriver.so $(TARGET_LIB_DIR)/libv3ddriver.so
	ln -sf libv3ddriver.so $(TARGET_LIB_DIR)/libEGL.so.1.4
	ln -sf libEGL.so.1.4 $(TARGET_LIB_DIR)/libEGL.so.1
	ln -sf libEGL.so.1 $(TARGET_LIB_DIR)/libEGL.so
	ln -sf libv3ddriver.so $(TARGET_LIB_DIR)/libGLESv1_CM.so.1.1
	ln -sf libGLESv1_CM.so.1.1 $(TARGET_LIB_DIR)/libGLESv1_CM.so.1
	ln -sf libGLESv1_CM.so.1 $(TARGET_LIB_DIR)/libGLESv1_CM.so
	ln -sf libv3ddriver.so $(TARGET_LIB_DIR)/libGLESv2.so.2.0
	ln -sf libGLESv2.so.2.0 $(TARGET_LIB_DIR)/libGLESv2.so.2
	ln -sf libGLESv2.so.2 $(TARGET_LIB_DIR)/libGLESv2.so
	ln -sf libv3ddriver.so $(TARGET_LIB_DIR)/libgbm.so.1
	ln -sf libgbm.so.1 $(TARGET_LIB_DIR)/libgbm.so

$(D)/install-v3ddriver-header: $(ARCHIVE)/$(LIBGLES_HEADERS)
	install -d $(TARGET_INCLUDE_DIR)
	unzip -o $(PATCHES)/$(LIBGLES_HEADERS) -d $(TARGET_INCLUDE_DIR)
	install -d $(TARGET_LIB_DIR)/pkgconfig
	cp $(PATCHES)/glesv2.pc $(TARGET_LIB_DIR)/pkgconfig
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/glesv2.pc
	cp $(PATCHES)/glesv1_cm.pc $(TARGET_LIB_DIR)/pkgconfig
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/glesv1_cm.pc
	cp $(PATCHES)/egl.pc $(TARGET_LIB_DIR)/pkgconfig
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/egl.pc

$(D)/install-hisiplayer-libs: $(ARCHIVE)/$(PLAYERLIB_SRC)
	install -d $(BUILD_TMP)/hiplay
	unzip -o $(ARCHIVE)/$(PLAYERLIB_SRC) -d $(BUILD_TMP)/hiplay
	install -d $(TARGET_LIB_DIR)/hisilicon
	install -m 0755 $(BUILD_TMP)/hiplay/hisilicon/* $(TARGET_LIB_DIR)/hisilicon
	install -m 0755 $(BUILD_TMP)/hiplay/ffmpeg/* $(TARGET_LIB_DIR)/hisilicon
#	install -m 0755 $(BUILD_TMP)/hiplay/glibc/* $(TARGET_LIB_DIR)/hisilicon
	ln -sf /lib/ld-linux-armhf.so.3 $(TARGET_LIB_DIR)/hisilicon/ld-linux.so
	$(REMOVE)/hiplay

$(D)/install-tntfs: $(ARCHIVE)/$(TNTFS_SRC)
	install -d $(BUILD_TMP)/tntfs
	unzip -o $(ARCHIVE)/$(TNTFS_SRC) -d $(BUILD_TMP)/tntfs
	install -m 0755 $(BUILD_TMP)/tntfs/tntfs.ko $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	$(REMOVE)/tntfs

$(D)/install-libmali: $(ARCHIVE)/$(LIBMALI_SRC)
	install -d $(BUILD_TMP)/libmali
	unzip -o $(ARCHIVE)/$(LIBMALI_SRC) -d $(BUILD_TMP)/libmali
	install -d $(TARGET_LIB_DIR)/hisilicon
	install -d $(TARGET_DIR)/etc/udev/rules.d
	echo 'KERNEL=="mali0", MODE="0660", GROUP="video"' > $(BUILD_TMP)/libmali/50-mali.rules
	install -m 0644 $(BUILD_TMP)/libmali/50-mali.rules  $(TARGET_DIR)/etc/udev/rules.d/50-mali.rules
	install -m 0755 $(BUILD_TMP)/libmali/libMali.so $(TARGET_LIB_DIR)/hisilicon
	ln -sf /usr/lib/hisilicon/libMali.so $(TARGET_LIB_DIR)/hisilicon/libmali.so
	ln -sf /usr/lib/hisilicon/libMali.so $(TARGET_LIB_DIR)/hisilicon/libEGL.so.1.4
	ln -sf /usr/lib/hisilicon/libEGL.so.1.4 $(TARGET_LIB_DIR)/hisilicon/libEGL.so.1
	ln -sf /usr/lib/hisilicon/libEGL.so.1 $(TARGET_LIB_DIR)/hisilicon/libEGL.so
	ln -sf /usr/lib/hisilicon/libMali.so $(TARGET_LIB_DIR)/hisilicon/libGLESv1_CM.so.1.1
	ln -sf /usr/lib/hisilicon/libGLESv1_CM.so.1.1 $(TARGET_LIB_DIR)/hisilicon/libGLESv1_CM.so.1
	ln -sf /usr/lib/hisilicon/libGLESv1_CM.so.1 $(TARGET_LIB_DIR)/hisilicon/libGLESv1_CM.so
	ln -sf /usr/lib/hisilicon/libMali.so $(TARGET_LIB_DIR)/hisilicon/libGLESv2.so.2.0
	ln -sf /usr/lib/hisilicon/libGLESv2.so.2.0 $(TARGET_LIB_DIR)/hisilicon/libGLESv2.so.2
	ln -sf /usr/lib/hisilicon/libGLESv2.so.2 $(TARGET_LIB_DIR)/hisilicon/libGLESv2.so
	ln -sf /usr/lib/hisilicon/libMali.so $(TARGET_LIB_DIR)/hisilicon/libgbm.so.1
	ln -sf /usr/lib/hisilicon/libgbm.so.1 $(TARGET_LIB_DIR)/hisilicon/libgbm.so
	$(REMOVE)/libmali

$(D)/install-wifi: $(D)/bootstrap $(D)/kernel $(ARCHIVE)/$(WIFI_SRC)
	$(START_BUILD)
	$(REMOVE)/$(WIFI_DIR)
	unzip -o $(ARCHIVE)/$(WIFI) -d $(BUILD_TMP)
	echo $(KERNEL_DIR)
	$(CHDIR)/$(WIFI_DIR); \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- KVER=$(DRIVER_VER) KSRC=$(KERNEL_DIR); \
		install -m 644 8192fu.ko $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	$(REMOVE)/$(WIFI_DIR)
	$(TOUCH)

$(D)/mali-gpu-modul: $(ARCHIVE)/$(MALI_MODULE_SRC) $(D)/bootstrap $(D)/kernel
	$(START_BUILD)
	$(REMOVE)/$(MALI_MODULE_VER)
	$(UNTAR)/$(MALI_MODULE_SRC)
	$(CHDIR)/$(MALI_MODULE_VER); \
		$(call apply_patches, $(MALI_MODULE_PATCH)); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- \
		M=$(BUILD_TMP)/$(MALI_MODULE_VER)/driver/src/devicedrv/mali \
		EXTRA_CFLAGS="-DCONFIG_MALI_SHARED_INTERRUPTS=y \
		-DCONFIG_MALI400=m \
		-DCONFIG_MALI450=y \
		-DCONFIG_MALI_DVFS=y \
		-DCONFIG_GPU_AVS_ENABLE=y" \
		CONFIG_MALI_SHARED_INTERRUPTS=y \
		CONFIG_MALI400=m \
		CONFIG_MALI450=y \
		CONFIG_MALI_DVFS=y \
		CONFIG_GPU_AVS_ENABLE=y ; \
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- \
		M=$(BUILD_TMP)/$(MALI_MODULE_VER)/driver/src/devicedrv/mali \
		EXTRA_CFLAGS="-DCONFIG_MALI_SHARED_INTERRUPTS=y \
		-DCONFIG_MALI400=m \
		-DCONFIG_MALI450=y \
		-DCONFIG_MALI_DVFS=y \
		-DCONFIG_GPU_AVS_ENABLE=y" \
		CONFIG_MALI_SHARED_INTERRUPTS=y \
		CONFIG_MALI400=m \
		CONFIG_MALI450=y \
		CONFIG_MALI_DVFS=y \
		CONFIG_GPU_AVS_ENABLE=y \
		DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	ls $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra | sed s/.ko//g > $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/modules.default
	$(REMOVE)/$(MALI_MODULE_VER)
	$(TOUCH)
