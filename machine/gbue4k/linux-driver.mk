#
# driver
#

driver-clean:
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*

DRIVER_SRC = platform-util-${MACHINE}-${KERNEL_SRC_VER}-$(UTIL_DATE).$(UTIL_REV).zip

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) https://source.mynonpublic.com/gigablue/drivers/$(DRIVER_SRC)



driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
	$(START_BUILD)
	unzip -o $(ARCHIVE)/$(DRIVER_SRC) -d $(BUILD_TMP)/platform-util-$(KERNEL_TYPE)
	install -d $(TARGET_DIR)/usr/share/platform
	install -m 0755 $(BUILD_TMP)/platform-util-$(KERNEL_TYPE)/platform/* $(TARGET_DIR)/usr/share/platform/
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/
	install -m 0755 $(TARGET_DIR)/usr/share/platform/*.ko $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/
	install -m 0755 $(TARGET_DIR)/usr/share/platform/*.so $(TARGET_DIR)/usr/lib/
	install -m 0755 $(TARGET_DIR)/usr/share/platform/nxserver $(TARGET_DIR)/usr/bin/nxserver
	install -m 0755 $(TARGET_DIR)/usr/share/platform/dvb_init $(TARGET_DIR)/usr/bin/dvb_init
	$(REMOVE)/platform-util-$(KERNEL_TYPE)
	$(TOUCH)



