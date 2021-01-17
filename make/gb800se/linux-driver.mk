DRIVER_VER = 3.9.6
DRIVER_DATE = 20170803
DRIVER_SRC = gigablue-drivers-$(DRIVER_VER)-BCM7325-$(DRIVER_DATE).zip

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/gigablue/drivers/$(DRIVER_SRC)

driver-clean:
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/$(KERNEL_TYPE)*

driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	unzip -o $(ARCHIVE)/$(DRIVER_SRC) -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	$(TOUCH)
