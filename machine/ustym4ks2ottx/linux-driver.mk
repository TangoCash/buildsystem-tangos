#
# driver
#
HICHIPSET = 3798mv300
SOC_FAMILY = hisi3798mv300

DRIVER_SRC = $(BOXTYPE)-hiko-$(DRIVER_DATE).zip

HILIB_SRC = $(BOXTYPE)-hilib-$(HILIB_DATE).tar.gz

LIBGLES_SRC = $(SOC_FAMILY)-opengl-$(LIBGLES_DATE).tar.gz

LIBREADER_SRC = $(BOXTYPE)-libreader-$(LIBREADER_DATE).tar.gz

HIHALT_SRC = $(SOC_FAMILY)-hihalt-$(HIHALT_DATE).tar.gz

TNTFS_SRC = $(HICHIPSET)-tntfs-$(TNTFS_DATE).zip

LIBJPEG_SRC = libjpeg.so.8.2.2

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
	tar xzf $(ARCHIVE)/$(LIBREADER_SRC) -C $(BUILD_TMP)/libreader
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
	cd $(TARGET_LIB_DIR); ln -sf $(LIBJPEG_SRC) ./libjpeg.so.8
