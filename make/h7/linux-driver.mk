#
# driver
#
DRIVER_VER = 4.10.12
DRIVER_DATE = 20190405
DRIVER_SRC = $(KERNEL_TYPE)-drivers-$(DRIVER_VER)-$(DRIVER_DATE).zip

LIBGLES_DATE = 20170320
LIBGLES_SRC = $(KERNEL_TYPE)-v3ddriver-$(LIBGLES_DATE).zip

LIBGLES_HEADERS = hd-v3ddriver-headers.tar.gz

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/zgemma/$(DRIVER_SRC)

$(ARCHIVE)/$(LIBGLES_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/zgemma/$(LIBGLES_SRC)

$(ARCHIVE)/$(LIBGLES_HEADERS):
	$(DOWNLOAD) http://downloads.mutant-digital.net/v3ddriver/$(LIBGLES_HEADERS)

driver-clean:
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/$(KERNEL_TYPE)*

driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	unzip -o $(ARCHIVE)/$(DRIVER_SRC) -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	ls $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra | sed s/.ko//g > $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/modules.default
	$(MAKE) install-v3ddriver
	$(MAKE) install-v3ddriver-header
	$(TOUCH)

$(D)/install-v3ddriver: $(ARCHIVE)/$(LIBGLES_SRC)
	install -d $(TARGET_DIR)/usr/lib
	unzip -o $(ARCHIVE)/$(LIBGLES_SRC) -d $(TARGET_DIR)/usr/lib
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

$(D)/install-v3ddriver-header: $(ARCHIVE)/$(LIBGLES_HEADERS)
	install -d $(TARGET_DIR)/usr/include
	tar -xf $(ARCHIVE)/$(LIBGLES_HEADERS) -C $(TARGET_DIR)/usr/include