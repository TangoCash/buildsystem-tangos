#
# driver
#
HICHIPSET = 3798mv200
SOC_FAMILY = hisi3798mv200

DRIVER_SRC = $(BOXTYPE)-hiko-$(DRIVER_DATE).zip

HILIB_SRC = $(BOXTYPE)-hilib-$(HILIB_DATE).tar.gz

LIBGLES_SRC = $(BOXTYPE)-opengl-$(LIBGLES_DATE).tar.gz

LIBREADER_SRC = $(BOXTYPE)-libreader-$(LIBREADER_DATE).zip

HIHALT_SRC = $(BOXTYPE)-hihalt-$(HIHALT_DATE).tar.gz

TNTFS_SRC = $(HICHIPSET)-tntfs-$(TNTFS_DATE).zip

LIBJPEG_SRC = libjpeg.so.62.2.0

WIFI_DIR = RTL8192EU-master
WIFI_SRC = master.zip
WIFI = RTL8192EU.zip

WIFI2_DIR = RTL8822C-main
WIFI2_SRC = main.zip
WIFI2 = RTL8822C.zip

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/$(MACHINE)/$(DRIVER_SRC)

$(ARCHIVE)/$(HILIB_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/$(MACHINE)/$(HILIB_SRC)

$(ARCHIVE)/$(LIBGLES_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/$(MACHINE)/$(LIBGLES_SRC)

$(ARCHIVE)/$(LIBREADER_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/$(MACHINE)/$(LIBREADER_SRC)

$(ARCHIVE)/$(HIHALT_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/$(MACHINE)/$(HIHALT_SRC)

$(ARCHIVE)/$(TNTFS_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/tntfs/$(TNTFS_SRC)

$(ARCHIVE)/$(LIBJPEG_SRC):	
	$(DOWNLOAD) https://github.com/oe-alliance/oe-alliance-core/raw/5.3/meta-brands/meta-$(MACHINE)/recipes-graphics/files/$(LIBJPEG_SRC)

$(ARCHIVE)/$(WIFI_SRC):
	$(DOWNLOAD) https://github.com/zukon/RTL8192EU/archive/refs/heads/$(WIFI_SRC) -O $(ARCHIVE)/$(WIFI)

$(ARCHIVE)/$(WIFI2_SRC):
	$(DOWNLOAD) https://github.com/zukon/RTL8822C/archive/refs/heads/$(WIFI2_SRC) -O $(ARCHIVE)/$(WIFI2)

driver-clean:
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/$(KERNEL_TYPE)*

driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	unzip -o $(ARCHIVE)/$(DRIVER_SRC) -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	install -d $(TARGET_DIR)/bin
	mv $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/hiko/* $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	rmdir $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/hiko
	$(MAKE) install-tntfs
	$(MAKE) install-wifi
	$(MAKE) install-wifi2
	ls $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra | sed s/.ko//g > $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/modules.default
	$(MAKE) install-hisiplayer-libs
	$(MAKE) install-hilib
	$(MAKE) install-libjpeg
	$(MAKE) install-hihalt
	$(MAKE) install-libreader
	$(TOUCH)

$(D)/install-hilib: $(ARCHIVE)/$(HILIB_SRC)
	install -d $(BUILD_TMP)/hilib
	tar xzf $(ARCHIVE)/$(HILIB_SRC) -C $(BUILD_TMP)/hilib
	cp -R $(BUILD_TMP)/hilib/hilib/* $(TARGET_LIB_DIR)
	$(REMOVE)/hilib

$(D)/install-hisiplayer-libs: $(ARCHIVE)/$(LIBGLES_SRC)
	install -d $(BUILD_TMP)/hiplay
	tar xzf $(ARCHIVE)/$(LIBGLES_SRC) -C $(BUILD_TMP)/hiplay
	cp -d $(BUILD_TMP)/hiplay/usr/lib/* $(TARGET_LIB_DIR)
	$(REMOVE)/hiplay

$(D)/install-libreader: $(ARCHIVE)/$(LIBREADER_SRC)
	install -d $(BUILD_TMP)/libreader
	unzip -o $(ARCHIVE)/$(LIBREADER_SRC) -d $(BUILD_TMP)/libreader
	install -m 0755 $(BUILD_TMP)/libreader/libreader $(TARGET_DIR)/usr/bin/libreader
	$(REMOVE)/libreader

$(D)/install-tntfs: $(ARCHIVE)/$(TNTFS_SRC)
	install -d $(BUILD_TMP)/tntfs
	unzip -o $(ARCHIVE)/$(TNTFS_SRC) -d $(BUILD_TMP)/tntfs
	install -m 0755 $(BUILD_TMP)/tntfs/tntfs.ko $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	$(REMOVE)/tntfs

$(D)/install-hihalt: $(ARCHIVE)/$(HIHALT_SRC)
	install -d $(BUILD_TMP)/hihalt
	tar xzf $(ARCHIVE)/$(HIHALT_SRC) -C $(BUILD_TMP)/hihalt
	install -m 0755 $(BUILD_TMP)/hihalt/hihalt $(TARGET_DIR)/usr/bin/hihalt
	$(REMOVE)/hihalt

$(D)/install-libjpeg: $(ARCHIVE)/$(LIBJPEG_SRC)
	cp $(ARCHIVE)/$(LIBJPEG_SRC) $(TARGET_LIB_DIR)

$(D)/install-wifi: $(D)/bootstrap $(D)/kernel $(ARCHIVE)/$(WIFI_SRC)
	$(START_BUILD)
	$(REMOVE)/$(WIFI_DIR)
	unzip -o $(ARCHIVE)/$(WIFI) -d $(BUILD_TMP)
	echo $(KERNEL_DIR)
	$(CHDIR)/$(WIFI_DIR); \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- KVER=$(DRIVER_VER) KSRC=$(KERNEL_DIR); \
		install -m 644 8192eu.ko $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	$(REMOVE)/$(WIFI_DIR)
	$(TOUCH)

$(D)/install-wifi2: $(D)/bootstrap $(D)/kernel $(ARCHIVE)/$(WIFI2_SRC)
	$(START_BUILD)
	$(REMOVE)/$(WIFI2_DIR)
	unzip -o $(ARCHIVE)/$(WIFI2) -d $(BUILD_TMP)
	echo $(KERNEL_DIR)
	$(CHDIR)/$(WIFI2_DIR); \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- KVER=$(DRIVER_VER) KSRC=$(KERNEL_DIR); \
		install -m 644 88x2cu.ko $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	$(REMOVE)/$(WIFI2_DIR)
	$(TOUCH)
