$(D)/oscam-modern.do_prepare:
	rm -rf $(SOURCE_DIR)/oscam-svn
	rm -rf $(SOURCE_DIR)/oscam-svn.org
	[ -d "$(ARCHIVE)/oscam-svn-modern" ] && \
	(cd $(ARCHIVE)/oscam-svn-modern; svn up; cd "$(CDK_DIR)";); \
	[ -d "$(ARCHIVE)/oscam-svn-modern" ] || \
	svn checkout http://www.streamboard.tv/svn/oscam-addons/modern $(ARCHIVE)/oscam-svn-modern; \
	cp -ra $(ARCHIVE)/oscam-svn-modern $(SOURCE_DIR)/oscam-svn;\
	cp -ra $(SOURCE_DIR)/oscam-svn $(SOURCE_DIR)/oscam-svn.org;\
	cd $(SOURCE_DIR)/oscam-svn; \
	[ -e "$(PATCHES)/oscam.config" ] && \
	cp -ra "$(PATCHES)/oscam.config" config.h; \
	[ -e "$(PATCHES)/oscam.config" ] || \
	$(MAKE) config
	touch $@

$(D)/oscam-emu.do_prepare:
	rm -rf $(SOURCE_DIR)/oscam-svn
	rm -rf $(SOURCE_DIR)/oscam-svn.org
	[ -d "$(ARCHIVE)/oscam-svn" ] && \
	(cd $(ARCHIVE)/oscam-svn; svn up; cd "$(CDK_DIR)";); \
	[ -d "$(ARCHIVE)/oscam-svn" ] || \
	svn checkout http://www.streamboard.tv/svn/oscam/trunk $(ARCHIVE)/oscam-svn; \
	cp -ra $(ARCHIVE)/oscam-svn $(SOURCE_DIR)/oscam-svn;\
	cp -ra $(SOURCE_DIR)/oscam-svn $(SOURCE_DIR)/oscam-svn.org;\
	cd $(SOURCE_DIR)/oscam-svn; \
	wget https://github.com/oscam-emu/oscam-emu/raw/master/oscam-emu.patch; \
	sed -i 's/SoftCam\.Key/oscam.keys/ig' oscam-emu.patch; \
	sed -i 's/SoftCam_Key/oscam_keys/ig' oscam-emu.patch; \
	patch -p0 < ./oscam-emu.patch; \
	wget -O oscam.keys http://enigma.satupdate.net/SoftCam.txt ;\
	[ -e "$(PATCHES)/oscam.config" ] && \
	cp -ra "$(PATCHES)/oscam.config" config.h; \
	[ -e "$(PATCHES)/oscam.config" ] || \
	$(MAKE) config
	touch $@

$(D)/oscam.do_prepare:
	rm -rf $(SOURCE_DIR)/oscam-svn
	rm -rf $(SOURCE_DIR)/oscam-svn.org
	[ -d "$(ARCHIVE)/oscam-svn" ] && \
	(cd $(ARCHIVE)/oscam-svn; svn up; cd "$(CDK_DIR)";); \
	[ -d "$(ARCHIVE)/oscam-svn" ] || \
	svn checkout http://www.streamboard.tv/svn/oscam/trunk $(ARCHIVE)/oscam-svn; \
	cp -ra $(ARCHIVE)/oscam-svn $(SOURCE_DIR)/oscam-svn;\
	cp -ra $(SOURCE_DIR)/oscam-svn $(SOURCE_DIR)/oscam-svn.org;\
	cd $(SOURCE_DIR)/oscam-svn; \
	[ -e "$(PATCHES)/oscam.config" ] && \
	cp -ra "$(PATCHES)/oscam.config" config.h; \
	[ -e "$(PATCHES)/oscam.config" ] || \
	$(MAKE) config
	touch $@

$(D)/oscam.do_compile:
	cd $(SOURCE_DIR)/oscam-svn && \
		$(BUILDENV) \
		$(MAKE) CROSS=sh4-linux- CONF_DIR=/var/keys
	touch $@

$(D)/oscam-emu.do_compile:
	cd $(SOURCE_DIR)/oscam-svn && \
		$(BUILDENV) \
		$(MAKE) CROSS=sh4-linux- CONF_DIR=/var/keys VER=emu_svn
	touch $@

$(D)/oscam-ssl.do_compile: openssl
	cd $(SOURCE_DIR)/oscam-svn && \
		$(BUILDENV) \
		$(MAKE) CROSS=sh4-linux- USE_SSL=1 CONF_DIR=/var/keys VER=ssl_svn
	touch $@

$(D)/oscam-libusb.do_compile: libusb
	cd $(SOURCE_DIR)/oscam-svn && \
		$(BUILDENV) \
		$(MAKE) CROSS=sh4-linux- USE_LIBUSB=1 CONF_DIR=/var/keys VER=libusb_svn
	touch $@

$(D)/oscam: bootstrap oscam.do_prepare oscam.do_compile
	rm -rf $(TARGET_DIR)/../OScam
	mkdir $(TARGET_DIR)/../OScam
	cp -pR $(SOURCE_DIR)/oscam-svn/Distribution/* $(TARGET_DIR)/../OScam/ 
	touch $@

$(D)/oscam-ssl: bootstrap oscam.do_prepare oscam-ssl.do_compile
	rm -rf $(TARGET_DIR)/../OScam
	mkdir $(TARGET_DIR)/../OScam
	cp -pR $(SOURCE_DIR)/oscam-svn/Distribution/* $(TARGET_DIR)/../OScam/ 
	touch $@

$(D)/oscam-libusb: bootstrap oscam.do_prepare oscam-libusb.do_compile
	rm -rf $(TARGET_DIR)/../OScam
	mkdir $(TARGET_DIR)/../OScam
	cp -pR $(SOURCE_DIR)/oscam-svn/Distribution/* $(TARGET_DIR)/../OScam/ 
	touch $@

$(D)/oscam-modern: bootstrap oscam-modern.do_prepare oscam.do_compile
	rm -rf $(TARGET_DIR)/../OScam
	mkdir $(TARGET_DIR)/../OScam
	cp -pR $(SOURCE_DIR)/oscam-svn/Distribution/* $(TARGET_DIR)/../OScam/ 
	touch $@

$(D)/oscam-emu: bootstrap oscam-emu.do_prepare oscam-emu.do_compile
	rm -rf $(TARGET_DIR)/../OScam
	mkdir $(TARGET_DIR)/../OScam
	cp -pR $(SOURCE_DIR)/oscam-svn/oscam.keys $(TARGET_DIR)/../OScam/
	cp -pR $(SOURCE_DIR)/oscam-svn/Distribution/* $(TARGET_DIR)/../OScam/ 
	touch $@

oscam-clean:
	rm -f $(D)/oscam
	cd $(SOURCE_DIR)/oscam-svn && \
		$(MAKE) distclean

oscam-distclean:
	rm -f $(D)/oscam
	rm -f $(D)/oscam.do_compile
	rm -f $(D)/oscam-libusb.do_compile
	rm -f $(D)/oscam.do_prepare
	rm -f $(D)/oscam-modern.do_prepare

