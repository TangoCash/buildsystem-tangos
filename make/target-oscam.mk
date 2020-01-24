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
				\
				MODULE_CAMD35 \
				MODULE_CAMD35_TCP \
				MODULE_CCCAM \
				MODULE_CCCSHARE \
				MODULE_CONSTCW \
				MODULE_GBOX \
				MODULE_NEWCAMD \
				\
				CARDREADER_INTERNAL \
				CARDREADER_PHOENIX \
				CARDREADER_SC8IN1

$(D)/oscam-emu.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/oscam-svn*
	[ -d "$(ARCHIVE)/oscam-svn" ] && \
	(cd $(ARCHIVE)/oscam-svn; svn up;); \
	[ -d "$(ARCHIVE)/oscam-svn" ] || \
	svn checkout http://www.streamboard.tv/svn/oscam/trunk $(ARCHIVE)/oscam-svn; \
	cp -ra $(ARCHIVE)/oscam-svn $(SOURCE_DIR)/oscam-svn;\
	cp -ra $(SOURCE_DIR)/oscam-svn $(SOURCE_DIR)/oscam-svn.org;\
	cd $(SOURCE_DIR)/oscam-svn; \
		wget --progress=bar:force --no-check-certificate $(DOWNLOAD_SILENT_OPT) -t6 -T20 -O oscam-emu.patch https://github.com/oscam-emu/oscam-emu/raw/master/oscam-emu.patch; \
		sed -i 's/SoftCam\.Key/oscam.keys/ig' oscam-emu.patch; \
		sed -i 's/SoftCam_Key/oscam_keys/ig' oscam-emu.patch; \
		$(call apply_patches, $(SOURCE_DIR)/oscam-svn/oscam-emu.patch, 0); \
		wget --progress=bar:force --no-check-certificate $(DOWNLOAD_SILENT_OPT) -t6 -T20 -O oscam.keys http://enigma.satupdate.net/SoftCam.txt ;\
		$(OSCAM_CONFIG) \
			WITH_EMU \
			WITH_SOFTCAM \
			$(SILENT_OPT)
	touch $@

$(D)/oscam.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/oscam-svn*
	[ -d "$(ARCHIVE)/oscam-svn" ] && \
	(cd $(ARCHIVE)/oscam-svn; svn up;); \
	[ -d "$(ARCHIVE)/oscam-svn" ] || \
	svn checkout http://www.streamboard.tv/svn/oscam/trunk $(ARCHIVE)/oscam-svn; \
	cp -ra $(ARCHIVE)/oscam-svn $(SOURCE_DIR)/oscam-svn;\
	cp -ra $(SOURCE_DIR)/oscam-svn $(SOURCE_DIR)/oscam-svn.org;\
	cd $(SOURCE_DIR)/oscam-svn; \
		$(OSCAM_CONFIG) \
			$(SILENT_OPT)
	touch $@

$(D)/oscam.do_compile:
	cd $(SOURCE_DIR)/oscam-svn && \
		$(BUILDENV) \
		$(MAKE) EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" CROSS=$(TARGET)- CONF_DIR=/var/keys
	touch $@

$(D)/oscam-emu.do_compile: openssl
	cd $(SOURCE_DIR)/oscam-svn && \
		$(BUILDENV) \
		$(MAKE) EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" CROSS=$(TARGET)- USE_LIBCRYPTO=1 CONF_DIR=/var/keys VER=emu_svn
	touch $@

$(D)/oscam-ssl.do_compile: openssl
	cd $(SOURCE_DIR)/oscam-svn && \
		$(BUILDENV) \
		$(MAKE) EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" CROSS=$(TARGET)- USE_SSL=1 CONF_DIR=/var/keys VER=ssl_svn
	touch $@

$(D)/oscam-libusb.do_compile: libusb
	cd $(SOURCE_DIR)/oscam-svn && \
		$(BUILDENV) \
		$(MAKE) EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" CROSS=$(TARGET)- USE_LIBUSB=1 CONF_DIR=/var/keys VER=libusb_svn
	touch $@

$(D)/oscam: bootstrap oscam.do_prepare oscam.do_compile
	rm -rf $(TARGET_DIR)/../build_oscam
	mkdir $(TARGET_DIR)/../build_oscam
	cp -pR $(SOURCE_DIR)/oscam-svn/Distribution/* $(TARGET_DIR)/../build_oscam/
	rm -rf $(SOURCE_DIR)/oscam-svn*
	$(TOUCH)

$(D)/oscam-ssl: bootstrap oscam.do_prepare oscam-ssl.do_compile
	rm -rf $(TARGET_DIR)/../build_oscam
	mkdir $(TARGET_DIR)/../build_oscam
	cp -pR $(SOURCE_DIR)/oscam-svn/Distribution/* $(TARGET_DIR)/../build_oscam/
	rm -rf $(SOURCE_DIR)/oscam-svn*
	$(TOUCH)

$(D)/oscam-libusb: bootstrap oscam.do_prepare oscam-libusb.do_compile
	rm -rf $(TARGET_DIR)/../build_oscam
	mkdir $(TARGET_DIR)/../build_oscam
	cp -pR $(SOURCE_DIR)/oscam-svn/Distribution/* $(TARGET_DIR)/../build_oscam/
	rm -rf $(SOURCE_DIR)/oscam-svn*
	$(TOUCH)

$(D)/oscam-emu: bootstrap oscam-emu.do_prepare oscam-emu.do_compile
	rm -rf $(TARGET_DIR)/../build_oscam
	mkdir $(TARGET_DIR)/../build_oscam
	cp -pR $(SOURCE_DIR)/oscam-svn/oscam.keys $(TARGET_DIR)/../build_oscam/
	cp -pR $(SOURCE_DIR)/oscam-svn/Distribution/* $(TARGET_DIR)/../build_oscam/
	rm -rf $(SOURCE_DIR)/oscam-svn*
	$(TOUCH)

oscam-clean:
	rm -f $(D)/oscam
	cd $(SOURCE_DIR)/oscam-svn && \
		$(MAKE) distclean

oscam-distclean:
	rm -f $(D)/oscam
	rm -f $(D)/oscam-emu
	rm -f $(D)/oscam-libusb
	rm -f $(D)/oscam.do_compile
	rm -f $(D)/oscam-emu.do_compile
	rm -f $(D)/oscam-libusb.do_compile
	rm -f $(D)/oscam.do_prepare
	rm -f $(D)/oscam-emu.do_prepare
	rm -f $(D)/oscam-libusb.do_prepare

