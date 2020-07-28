#
# driver
#
DRIVER_DATE = 20200409
DRIVER_VER  = 5.5.16-$(DRIVER_DATE)
DRIVER_SRC  = osmio4kplus-drivers-$(DRIVER_VER).zip

LIBGLES_VER = 2.0
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
	for i in brcmstb-osmio4kplus ci si2183 avl6862 avl6261; do \
		echo $$i >> $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/modules.default; \
	done
	$(MAKE) install-v3ddriver
	$(MAKE) wlan-qcom
	$(TOUCH)

$(D)/install-v3ddriver: $(ARCHIVE)/$(LIBGLES_SRC)
	install -d $(TARGET_LIB_DIR)
	$(REMOVE)/$(LIBGLES_DIR)
	$(UNTAR)/$(LIBGLES_SRC)
	rm -rf $(BUILD_TMP)/$(LIBGLES_DIR)/lib
	mv $(BUILD_TMP)/$(LIBGLES_DIR)/lib64 $(BUILD_TMP)/$(LIBGLES_DIR)/lib
	cp -a $(BUILD_TMP)/$(LIBGLES_DIR)/* $(TARGET_DIR)/usr/
	ln -sf libv3ddriver.so.$(LIBGLES_VER) $(TARGET_LIB_DIR)/libEGL.so
	ln -sf libv3ddriver.so.$(LIBGLES_VER) $(TARGET_LIB_DIR)/libGLESv2.so
	$(REMOVE)/$(LIBGLES_DIR)

#
# wlan-qcom osmio4k | osmio4kplus
#
WLAN_QCOM_VER    = 4.5.25.38
WLAN_QCOM_DIR    = qcacld-2.0-$(WLAN_QCOM_VER)
WLAN_QCOM_SOURCE = qcacld-2.0-$(WLAN_QCOM_VER).tar.gz
WLAN_QCOM_URL    = https://www.codeaurora.org/cgit/external/wlan/qcacld-2.0/snapshot

$(ARCHIVE)/$(WLAN_QCOM_SOURCE):
	$(DOWNLOAD) $(WLAN_QCOM_URL)/$(WLAN_QCOM_SOURCE)

WLAN_QCOM_PATCH  = \
	qcacld-2.0-support.patch

$(D)/wlan-qcom: $(D)/bootstrap $(D)/kernel $(D)/wlan-qcom-firmware $(ARCHIVE)/$(WLAN_QCOM_SOURCE)
	$(START_BUILD)
	$(REMOVE)/$(WLAN_QCOM_DIR)
	$(UNTAR)/$(WLAN_QCOM_SOURCE)
	$(CHDIR)/$(WLAN_QCOM_DIR); \
		$(call apply_patches, $(WLAN_QCOM_PATCH)); \
		$(MAKE) KERNEL_SRC=$(KERNEL_DIR) ARCH=arm64 CROSS_COMPILE=$(TARGET)- CROSS_COMPILE_COMPAT=$(TARGET)- all; \
	install -m 644 wlan.ko $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	$(REMOVE)/$(WLAN_QCOM_DIR)
	$(TOUCH)

#
# wlan-qcom-firmware
#
WLAN_QCOM_FIRMWARE_VER    = qca6174
WLAN_QCOM_FIRMWARE_DIR    = firmware-$(WLAN_QCOM_FIRMWARE_VER)
WLAN_QCOM_FIRMWARE_SOURCE = firmware-$(WLAN_QCOM_FIRMWARE_VER).zip
WLAN_QCOM_FIRMWARE_URL    = http://source.mynonpublic.com/edision

$(ARCHIVE)/$(WLAN_QCOM_FIRMWARE_SOURCE):
	$(DOWNLOAD) $(WLAN_QCOM_FIRMWARE_URL)/$(WLAN_QCOM_FIRMWARE_SOURCE)

$(D)/wlan-qcom-firmware: $(D)/bootstrap $(ARCHIVE)/$(WLAN_QCOM_FIRMWARE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/$(WLAN_QCOM_FIRMWARE_DIR)
	unzip -o $(ARCHIVE)/$(WLAN_QCOM_FIRMWARE_SOURCE) -d $(BUILD_TMP)/$(WLAN_QCOM_FIRMWARE_DIR)
	$(CHDIR)/$(WLAN_QCOM_FIRMWARE_DIR); \
		install -d $(TARGET_DIR)/lib/firmware/ath10k/QCA6174/hw3.0; \
		install -m 644 board.bin $(TARGET_DIR)/lib/firmware/ath10k/QCA6174/hw3.0/board.bin; \
		install -m 644 firmware-4.bin $(TARGET_DIR)/lib/firmware/ath10k/QCA6174/hw3.0/firmware-4.bin; \
		install -d $(TARGET_DIR)/lib/firmware/wlan; \
		install -m 644 bdwlan30.bin $(TARGET_DIR)/lib/firmware/bdwlan30.bin; \
		install -m 644 otp30.bin $(TARGET_DIR)/lib/firmware/otp30.bin; \
		install -m 644 qwlan30.bin $(TARGET_DIR)/lib/firmware/qwlan30.bin; \
		install -m 644 utf30.bin $(TARGET_DIR)/lib/firmware/utf30.bin; \
		install -m 644 wlan/cfg.dat $(TARGET_DIR)/lib/firmware/wlan/cfg.dat; \
		install -m 644 wlan/qcom_cfg.ini $(TARGET_DIR)/lib/firmware/wlan/qcom_cfg.ini; \
		install -m 644 btfw32.tlv $(TARGET_DIR)/lib/firmware/btfw32.tlv
	$(REMOVE)/$(WLAN_QCOM_FIRMWARE_DIR)
	$(TOUCH)
