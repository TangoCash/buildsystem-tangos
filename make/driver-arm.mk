#
# driver
#
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd51 bre2ze4k))
DRIVER_VER = 4.10.12
DRIVER_DATE = 20180424
DRIVER_SRC = $(KERNEL_TYPE)-drivers-$(DRIVER_VER)-$(DRIVER_DATE).zip

EXTRA_LIBGLES_DATE = 20170322
EXTRA_LIBGLES_SRC = $(KERNEL_TYPE)-v3ddriver-$(EXTRA_LIBGLES_DATE).zip

EXTRA_LIBGLES_HEADERS = hd-v3ddriver-headers.tar.gz

$(ARCHIVE)/$(DRIVER_SRC):
	$(WGET) http://source.mynonpublic.com/gfutures/$(DRIVER_SRC)

$(ARCHIVE)/$(EXTRA_LIBGLES_SRC):
	$(WGET) http://downloads.mutant-digital.net/v3ddriver/$(EXTRA_LIBGLES_SRC)

$(ARCHIVE)/$(EXTRA_LIBGLES_HEADERS):
	$(WGET) http://downloads.mutant-digital.net/v3ddriver/$(EXTRA_LIBGLES_HEADERS)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd60))
DRIVER_DATE = 20190319
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd61))
DRIVER_DATE = 20181221
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd60 hd61))
DRIVER_VER = 4.4.35
DRIVER_SRC = $(KERNEL_TYPE)-drivers-$(DRIVER_VER)-$(DRIVER_DATE).zip

EXTRA_PLAYERLIB_DATE = 20190120
EXTRA_PLAYERLIB_SRC = $(KERNEL_TYPE)-libs-$(EXTRA_PLAYERLIB_DATE).zip

EXTRA_LIBGLES_DATE = 20181201
EXTRA_LIBGLES_SRC = $(KERNEL_TYPE)-mali-$(EXTRA_LIBGLES_DATE).zip

EXTRA_LIBGLES_HEADERS = libgles-mali-utgard-headers.zip

EXTRA_MALI_MODULE_VER = DX910-SW-99002-r7p0-00rel0
EXTRA_MALI_MODULE_SRC = $(EXTRA_MALI_MODULE_VER).tgz
EXTRA_MALI_MODULE_PATCH = 0001-hi3798mv200-support.patch

$(ARCHIVE)/$(DRIVER_SRC):
	$(WGET) http://downloads.mutant-digital.net/$(KERNEL_TYPE)/$(DRIVER_SRC)

$(ARCHIVE)/$(EXTRA_PLAYERLIB_SRC):
	$(WGET) http://downloads.mutant-digital.net/$(KERNEL_TYPE)/$(EXTRA_PLAYERLIB_SRC)

$(ARCHIVE)/$(EXTRA_LIBGLES_SRC):
	$(WGET) http://downloads.mutant-digital.net/$(KERNEL_TYPE)/$(EXTRA_LIBGLES_SRC)

$(ARCHIVE)/$(EXTRA_MALI_MODULE_SRC):
	$(WGET) https://developer.arm.com/-/media/Files/downloads/mali-drivers/kernel/mali-utgard-gpu/$(EXTRA_MALI_MODULE_SRC);name=driver

endif

ifeq ($(BOXTYPE), vusolo4k)
DRIVER_VER = 3.14.28
DRIVER_DATE = 20181204
DRIVER_REV = r0
DRIVER_SRC = vuplus-dvb-proxy-$(KERNEL_TYPE)-$(DRIVER_VER)-$(DRIVER_DATE).$(DRIVER_REV).tar.gz

$(ARCHIVE)/$(DRIVER_SRC):
	$(WGET) http://archive.vuplus.com/download/build_support/vuplus/$(DRIVER_SRC)
endif

driver-clean:
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/$(KERNEL_TYPE)*

driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd51 bre2ze4k))
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	unzip -o $(ARCHIVE)/$(DRIVER_SRC) -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	ls $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra | sed s/.ko//g > $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/modules.default
	$(MAKE) install-extra-libs
	$(TOUCH)

$(D)/install-extra-libs: $(ARCHIVE)/$(EXTRA_LIBGLES_HEADERS) $(ARCHIVE)/$(EXTRA_LIBGLES_SRC)
	install -d $(TARGET_DIR)/usr/lib
	tar -xf $(ARCHIVE)/$(EXTRA_LIBGLES_HEADERS) -C $(TARGET_DIR)/usr/include
	unzip -o $(ARCHIVE)/$(EXTRA_LIBGLES_SRC) -d $(TARGET_DIR)/usr/lib
	#patchelf --set-soname libv3ddriver.so $(TARGET_DIR)/usr/lib/libv3ddriver.so
	ln -sf libv3ddriver.so $(TARGET_DIR)/usr/lib/libEGL.so.1.4
	ln -sf libEGL.so.1.4 $(TARGET_DIR)/usr/lib/libEGL.so.1
	ln -sf libEGL.so.1 $(TARGET_DIR)/usr/lib/libEGL.so
	ln -sf libv3ddriver.so $(TARGET_DIR)/usr/lib/libGLESv1_CM.so.1.1
	ln -sf libGLESv1_CM.so.1.1 $(TARGET_DIR)/usr/lib/libGLESv1_CM.so.1
	ln -sf libGLESv1_CM.so.1 $(TARGET_DIR)/usr/lib/libGLESv1_CM.so
	ln -sf libv3ddriver.so $(TARGET_DIR)/usr/lib/libGLESv2.so.2.0
	ln -sf libGLESv2.so.2.0 $(TARGET_DIR)/usr/lib/libGLESv2.so.2
	ln -sf libGLESv2.so.2 $(TARGET_DIR)/usr/lib/libGLESv2.so
	ln -sf libv3ddriver.so $(TARGET_DIR)/usr/lib/libgbm.so.1
	ln -sf libgbm.so.1 $(TARGET_DIR)/usr/lib/libgbm.so
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd60 hd61))
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	unzip -o $(ARCHIVE)/$(DRIVER_SRC) -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	install -d $(TARGET_DIR)/bin
	mv $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/turnoff_power $(TARGET_DIR)/bin
	ls $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra | sed s/.ko//g > $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/modules.default
	$(MAKE) install-extra-libs
	$(MAKE) install-extra-preq
	$(MAKE) mali-gpu-modul
	$(TOUCH)

$(D)/install-extra-libs: $(ARCHIVE)/$(EXTRA_PLAYERLIB_SRC) $(ARCHIVE)/$(EXTRA_LIBGLES_SRC)
	install -d $(TARGET_DIR)/usr/lib
	install -d $(BUILD_TMP)/hiplay
	unzip -o $(ARCHIVE)/$(EXTRA_PLAYERLIB_SRC) -d $(BUILD_TMP)/hiplay
	install -d $(TARGET_DIR)/usr/lib/hisilicon
	install -m 0755 $(BUILD_TMP)/hiplay/hisilicon/* $(TARGET_DIR)/usr/lib/hisilicon
	install -m 0755 $(BUILD_TMP)/hiplay/ffmpeg/* $(TARGET_DIR)/usr/lib/hisilicon
	#install -m 0755 $(BUILD_TMP)/hiplay/glibc/* $(TARGET_DIR)/usr/lib/hisilicon
	ln -sf /lib/ld-linux-armhf.so.3 $(TARGET_DIR)/usr/lib/hisilicon/ld-linux.so
	$(REMOVE)/hiplay
	unzip -o $(PATCHES)/$(EXTRA_LIBGLES_HEADERS) -d $(TARGET_DIR)/usr/include
	unzip -o $(ARCHIVE)/$(EXTRA_LIBGLES_SRC) -d $(TARGET_DIR)/usr/lib
	ln -sf libMali.so $(TARGET_DIR)/usr/lib/libmali.so
	ln -sf libMali.so $(TARGET_DIR)/usr/lib/libEGL.so.1.4
	ln -sf libEGL.so.1.4 $(TARGET_DIR)/usr/lib/libEGL.so.1
	ln -sf libEGL.so.1 $(TARGET_DIR)/usr/lib/libEGL.so
	ln -sf libMali.so $(TARGET_DIR)/usr/lib/libGLESv1_CM.so.1.1
	ln -sf libGLESv1_CM.so.1.1 $(TARGET_DIR)/usr/lib/libGLESv1_CM.so.1
	ln -sf libGLESv1_CM.so.1 $(TARGET_DIR)/usr/lib/libGLESv1_CM.so
	ln -sf libMali.so $(TARGET_DIR)/usr/lib/libGLESv2.so.2.0
	ln -sf libGLESv2.so.2.0 $(TARGET_DIR)/usr/lib/libGLESv2.so.2
	ln -sf libGLESv2.so.2 $(TARGET_DIR)/usr/lib/libGLESv2.so
	ln -sf libMali.so $(TARGET_DIR)/usr/lib/libgbm.so
	install -d $(TARGET_DIR)/usr/lib/pkgconfig
	cp $(PATCHES)/glesv2.pc $(TARGET_DIR)/usr/lib/pkgconfig
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/glesv2.pc
	cp $(PATCHES)/glesv1_cm.pc $(TARGET_DIR)/usr/lib/pkgconfig
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/glesv1_cm.pc
	cp $(PATCHES)/egl.pc $(TARGET_DIR)/usr/lib/pkgconfig
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/egl.pc

$(D)/install-extra-preq: $(D)/zlib $(D)/libpng $(D)/freetype $(D)/libcurl $(D)/libxml2 $(D)/libjpeg_turbo2 $(D)/harfbuzz

$(D)/mali-gpu-modul: $(ARCHIVE)/$(EXTRA_MALI_MODULE_SRC) $(D)/bootstrap $(D)/kernel
	$(START_BUILD)
	$(REMOVE)/$(EXTRA_MALI_MODULE_VER)
	$(UNTAR)/$(EXTRA_MALI_MODULE_SRC)
	$(CHDIR)/$(EXTRA_MALI_MODULE_VER); \
		$(call apply_patches, $(EXTRA_MALI_MODULE_PATCH)); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- \
		M=$(BUILD_TMP)/$(EXTRA_MALI_MODULE_VER)/driver/src/devicedrv/mali \
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
		M=$(BUILD_TMP)/$(EXTRA_MALI_MODULE_VER)/driver/src/devicedrv/mali \
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
	$(REMOVE)/$(EXTRA_MALI_MODULE_VER)
	$(TOUCH)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vusolo4k vuduo4k))
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	tar -xf $(ARCHIVE)/$(DRIVER_SRC) -C $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	$(MAKE) platform_util
	$(MAKE) libgles
	$(MAKE) vmlinuz_initrd
	$(TOUCH)

#
# platform util
#
ifeq ($(BOXTYPE), vusolo4k)
UTIL_VER = 17.1
UTIL_DATE = 20190424
UTIL_REV = r0
endif
ifeq ($(BOXTYPE), vuduo4k)
UTIL_VER = 18.1
UTIL_DATE = 20190424
UTIL_REV = r0
endif
UTIL_SRC = platform-util-$(KERNEL_TYPE)-$(UTIL_VER)-$(UTIL_DATE).$(UTIL_REV).tar.gz

$(ARCHIVE)/$(UTIL_SRC):
	$(WGET) http://archive.vuplus.com/download/build_support/vuplus/$(UTIL_SRC)

$(D)/platform_util: $(D)/bootstrap $(ARCHIVE)/$(UTIL_SRC)
	$(START_BUILD)
	$(UNTAR)/$(UTIL_SRC)
	install -m 0755 $(BUILD_TMP)/platform-util-$(KERNEL_TYPE)/* $(TARGET_DIR)/usr/bin
	$(REMOVE)/platform-util-$(KERNEL_TYPE)
	$(TOUCH)

#
# libgles
#
ifeq ($(BOXTYPE), vusolo4k)
GLES_VER = 17.1
GLES_DATE = 20190424
GLES_REV = r0
endif
ifeq ($(BOXTYPE), vuduo4k)
GLES_VER = 18.1
GLES_DATE = 20190424
GLES_REV = r0
endif
GLES_SRC = libgles-$(KERNEL_TYPE)-$(GLES_VER)-$(GLES_DATE).$(GLES_REV).tar.gz

$(ARCHIVE)/$(GLES_SRC):
	$(WGET) http://archive.vuplus.com/download/build_support/vuplus/$(GLES_SRC)

$(D)/libgles: $(D)/bootstrap $(ARCHIVE)/$(GLES_SRC)
	$(START_BUILD)
	$(UNTAR)/$(GLES_SRC)
	install -m 0755 $(BUILD_TMP)/libgles-$(KERNEL_TYPE)/lib/* $(TARGET_DIR)/usr/lib
	ln -sf libv3ddriver.so $(TARGET_DIR)/usr/lib/libEGL.so
	ln -sf libv3ddriver.so $(TARGET_DIR)/usr/lib/libGLESv2.so
	cp -a $(BUILD_TMP)/libgles-$(KERNEL_TYPE)/include/* $(TARGET_DIR)/usr/include
	$(REMOVE)/libgles-$(KERNEL_TYPE)
	$(TOUCH)

#
# vmlinuz initrd
#
ifeq ($(BOXTYPE), vusolo4k)
INITRD_DATE = 20170209
endif
ifeq ($(BOXTYPE), vuduo4k)
INITRD_DATE = 20181030
endif
INITRD_SRC = vmlinuz-initrd_$(KERNEL_TYPE)_$(INITRD_DATE).tar.gz

$(ARCHIVE)/$(INITRD_SRC):
	$(WGET) http://archive.vuplus.com/download/kernel/$(INITRD_SRC)

$(D)/vmlinuz_initrd: $(D)/bootstrap $(ARCHIVE)/$(INITRD_SRC)
	$(START_BUILD)
	tar -xf $(ARCHIVE)/$(INITRD_SRC) -C $(TARGET_DIR)/boot
	install -d $(TARGET_DIR)/boot
	$(TOUCH)
endif
