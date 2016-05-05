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
	[ -e "$(CDK_DIR)/Patches/oscam.config" ] && \
	cp -ra "$(CDK_DIR)/Patches/oscam.config" config.h; \
	[ -e "$(CDK_DIR)/Patches/oscam.config" ] || \
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
	patch -p0 < ./oscam-emu.patch; \
	wget -O SoftCam.Key http://www.uydu.ws/deneme6.php?file=SoftCam.Key ;\
	[ -e "$(CDK_DIR)/Patches/oscam.config" ] && \
	cp -ra "$(CDK_DIR)/Patches/oscam.config" config.h; \
	[ -e "$(CDK_DIR)/Patches/oscam.config" ] || \
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
	[ -e "$(CDK_DIR)/Patches/oscam.config" ] && \
	cp -ra "$(CDK_DIR)/Patches/oscam.config" config.h; \
	[ -e "$(CDK_DIR)/Patches/oscam.config" ] || \
	$(MAKE) config
	touch $@

$(D)/oscam.do_compile:
	cd $(SOURCE_DIR)/oscam-svn && \
		$(BUILDENV) \
		$(MAKE) CROSS=sh4-linux- CONF_DIR=/var/keys
	touch $@

$(D)/oscam-ssl.do_compile: openssl
	cd $(SOURCE_DIR)/oscam-svn && \
		$(BUILDENV) \
		$(MAKE) CROSS=sh4-linux- USE_SSL=1 CONF_DIR=/var/keys
	touch $@

$(D)/oscam-libusb.do_compile: libusb
	cd $(SOURCE_DIR)/oscam-svn && \
		$(BUILDENV) \
		$(MAKE) CROSS=sh4-linux- USE_LIBUSB=1 CONF_DIR=/var/keys
	touch $@

$(D)/oscam: bootstrap oscam.do_prepare oscam.do_compile
	rm -rf $(TARGETPREFIX)/../OScam
	mkdir $(TARGETPREFIX)/../OScam
	cp -pR $(SOURCE_DIR)/oscam-svn/Distribution/* $(TARGETPREFIX)/../OScam/ 
	touch $@

$(D)/oscam-ssl: bootstrap oscam.do_prepare oscam-ssl.do_compile
	rm -rf $(TARGETPREFIX)/../OScam
	mkdir $(TARGETPREFIX)/../OScam
	cp -pR $(SOURCE_DIR)/oscam-svn/Distribution/* $(TARGETPREFIX)/../OScam/ 
	touch $@

$(D)/oscam-libusb: bootstrap oscam.do_prepare oscam-libusb.do_compile
	rm -rf $(TARGETPREFIX)/../OScam
	mkdir $(TARGETPREFIX)/../OScam
	cp -pR $(SOURCE_DIR)/oscam-svn/Distribution/* $(TARGETPREFIX)/../OScam/ 
	touch $@

$(D)/oscam-modern: bootstrap oscam-modern.do_prepare oscam.do_compile
	rm -rf $(TARGETPREFIX)/../OScam
	mkdir $(TARGETPREFIX)/../OScam
	cp -pR $(SOURCE_DIR)/oscam-svn/Distribution/* $(TARGETPREFIX)/../OScam/ 
	touch $@

$(D)/oscam-emu: bootstrap oscam-emu.do_prepare oscam.do_compile
	rm -rf $(TARGETPREFIX)/../OScam
	mkdir $(TARGETPREFIX)/../OScam
	cp -pR $(SOURCE_DIR)/oscam-svn/Distribution/* $(TARGETPREFIX)/../OScam/ 
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

