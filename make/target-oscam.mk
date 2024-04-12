OSCAM_CONFIG = \
		./config.sh \
			--disable all \
			--enable readers \
			--enable \
				WEBIF \
				CS_CACHEEX \
				HAVE_DVBAPI \
				MODULE_MONITOR \
				READ_SDT_CHARSETS \
				WEBIF_JQUERY \
				WEBIF_LIVELOG \
				WITH_DEBUG \
				WITH_EMU \
				WITH_LB \
				WITH_NEUTRINO \
				WITH_ARM_NEON \
				\
				MODULE_CAMD35 \
				MODULE_CAMD35_TCP \
				MODULE_CCCAM \
				MODULE_CCCSHARE \
				MODULE_CONSTCW \
				MODULE_GBOX \
				MODULE_NEWCAMD \
				MODULE_STREAMRELAY \
				\
				CARDREADER_INTERNAL \
				CARDREADER_PHOENIX \
				CARDREADER_SC8IN1

OSCAM_GIT = https://git.streamboard.tv/common/oscam.git

$(D)/oscam-emu.do_prepare:
	$(START_BUILD)
	$(REMOVE)/$(PKG_NAME)
	$(call update_git, $(OSCAM_GIT))
	$(CHDIR)/$(PKG_NAME); \
		wget --progress=bar:force --no-check-certificate $(DOWNLOAD_SILENT_OPT) -t6 -T20 -O oscam-emu.patch $(GITHUB)/oscam-emu/oscam-emu/raw/master/oscam-emu.patch; \
		sed -i 's/SoftCam\.Key/oscam.keys/ig' oscam-emu.patch; \
		sed -i 's/SoftCam_Key/oscam_keys/ig' oscam-emu.patch; \
		$(call apply_patches, $(BUILD_TMP)/$(PKG_NAME)/oscam-emu.patch, 0); \
		$(call apply_patches, $(LOCAL_OSCAM_EMU_PATCHES)); \
		wget --progress=bar:force --no-check-certificate $(DOWNLOAD_SILENT_OPT) -t6 -T20 -O oscam.keys http://enigma.satupdate.net/SoftCam.txt ;\
		$(OSCAM_CONFIG) \
			WITH_EMU \
			WITH_SOFTCAM \
			$(SILENT_OPT)
	touch $@

$(D)/oscam.do_prepare:
	$(START_BUILD)
	$(REMOVE)/$(PKG_NAME)
	$(call update_git, $(OSCAM_GIT))
	$(CHDIR)/$(PKG_NAME); \
		$(call apply_patches, $(LOCAL_OSCAM_PATCHES)); \
		$(OSCAM_CONFIG) \
			$(SILENT_OPT)
	touch $@

$(D)/oscam.do_compile:
	cd $(BUILD_TMP)/oscam && \
		$(BUILDENV) \
		$(MAKE) EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" CROSS=$(TARGET)- CONF_DIR=/var/keys VER=static_ LIBDVBCSA_LIB=$(TARGET_LIB_DIR)/libdvbcsa.a
	touch $@

$(D)/oscam-emu.do_compile: openssl
	cd $(BUILD_TMP)/oscam && \
		$(BUILDENV) \
		$(MAKE) EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" CROSS=$(TARGET)- USE_LIBCRYPTO=1 CONF_DIR=/var/keys VER=static_emu_ LIBDVBCSA_LIB=$(TARGET_LIB_DIR)/libdvbcsa.a
	touch $@

$(D)/oscam-ssl.do_compile: openssl
	cd $(BUILD_TMP)/oscam && \
		$(BUILDENV) \
		$(MAKE) EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" CROSS=$(TARGET)- USE_SSL=1 CONF_DIR=/var/keys VER=static_ssl_ LIBDVBCSA_LIB=$(TARGET_LIB_DIR)/libdvbcsa.a
	touch $@

$(D)/oscam-libusb.do_compile: libusb
	cd $(BUILD_TMP)/oscam && \
		$(BUILDENV) \
		$(MAKE) EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" CROSS=$(TARGET)- USE_LIBUSB=1 CONF_DIR=/var/keys VER=static_libusb_ LIBDVBCSA_LIB=$(TARGET_LIB_DIR)/libdvbcsa.a
	touch $@

$(D)/oscam: bootstrap libdvbcsa oscam.do_prepare oscam.do_compile
	rm -rf $(TARGET_DIR)/../build_oscam
	mkdir $(TARGET_DIR)/../build_oscam
	cp -pR $(BUILD_TMP)/oscam/Distribution/* $(TARGET_DIR)/../build_oscam/
	rm -rf $(BUILD_TMP)/oscam*
	$(TOUCH)

$(D)/oscam-ssl: bootstrap libdvbcsa openssl oscam.do_prepare oscam-ssl.do_compile
	rm -rf $(TARGET_DIR)/../build_oscam
	mkdir $(TARGET_DIR)/../build_oscam
	cp -pR $(BUILD_TMP)/oscam/Distribution/* $(TARGET_DIR)/../build_oscam/
	rm -rf $(BUILD_TMP)/oscam*
	$(TOUCH)

$(D)/oscam-libusb: bootstrap libdvbcsa oscam.do_prepare oscam-libusb.do_compile
	rm -rf $(TARGET_DIR)/../build_oscam
	mkdir $(TARGET_DIR)/../build_oscam
	cp -pR $(BUILD_TMP)/oscam/Distribution/* $(TARGET_DIR)/../build_oscam/
	rm -rf $(BUILD_TMP)/oscam*
	$(TOUCH)

$(D)/oscam-emu: bootstrap libdvbcsa oscam-emu.do_prepare oscam-emu.do_compile
	rm -rf $(TARGET_DIR)/../build_oscam
	mkdir $(TARGET_DIR)/../build_oscam
	cp -pR $(BUILD_TMP)/oscam/oscam.keys $(TARGET_DIR)/../build_oscam/
	cp -pR $(BUILD_TMP)/oscam/Distribution/* $(TARGET_DIR)/../build_oscam/
	rm -rf $(BUILD_TMP)/oscam*
	$(TOUCH)

oscam-clean:
	rm -f $(D)/oscam
	cd $(BUILD_TMP)/oscam && \
		$(MAKE) distclean

oscam-distclean:
	rm -f $(D)/oscam
	rm -f $(D)/oscam-emu
	rm -f $(D)/oscam-ssl
	rm -f $(D)/oscam-libusb
	rm -f $(D)/oscam.*
	rm -f $(D)/oscam-emu.*
	rm -f $(D)/oscam-ssl.*
	rm -f $(D)/oscam-libusb.*
