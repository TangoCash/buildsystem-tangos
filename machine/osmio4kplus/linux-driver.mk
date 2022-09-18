#
# driver
#
DRIVER_SRC  = osmio4kplus-drivers-$(DRIVER_VER).zip

LIBGLES_DIR = edision-libv3d-$(LIBGLES_VER)
LIBGLES_SRC = edision-libv3d-$(LIBGLES_VER).tar.xz


$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/edision/$(DRIVER_SRC)

$(ARCHIVE)/$(LIBGLES_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/edision/$(LIBGLES_SRC)

driver-clean:
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/$(KERNEL_TYPE)*

driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	unzip -o $(ARCHIVE)/$(DRIVER_SRC) -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	rm -f $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/modules.default
	for i in brcmstb-osmio4kplus brcmstb-decoder ci si2183 avl6862 avl6261; do \
		echo $$i >> $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/modules.default; \
	done
	$(MAKE) install-v3ddriver
	$(MAKE) wlan-qcom
	$(TOUCH)

$(D)/install-v3ddriver: $(ARCHIVE)/$(LIBGLES_SRC)
	install -d $(TARGET_LIB_DIR)
	$(REMOVE)/$(LIBGLES_DIR)
	$(UNTAR)/$(LIBGLES_SRC)
	cp -a $(BUILD_TMP)/$(LIBGLES_DIR)/* $(TARGET_DIR)/usr/
	ln -sf libv3ddriver.so.$(LIBGLES_VER) $(TARGET_LIB_DIR)/libEGL.so
	ln -sf libv3ddriver.so.$(LIBGLES_VER) $(TARGET_LIB_DIR)/libGLESv2.so
	$(REMOVE)/$(LIBGLES_DIR)
