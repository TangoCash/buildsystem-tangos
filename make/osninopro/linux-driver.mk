DRIVER_VER = 4.8.17
DRIVER_DATE = 20201104
DRIVER_SRC = osninopro-drivers-$(DRIVER_VER)-$(DRIVER_DATE).zip

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/edision/$(DRIVER_SRC)

driver-clean:
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/$(KERNEL_TYPE)*

driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	unzip -o $(ARCHIVE)/$(DRIVER_SRC) -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	$(TOUCH)
