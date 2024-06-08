#
# hddtemp
#
HDDTEMP_VER = 0.3-beta15
HDDTEMP_SOURCE = hddtemp-$(HDDTEMP_VER).tar.bz2

$(ARCHIVE)/$(HDDTEMP_SOURCE):
	$(DOWNLOAD) http://savannah.c3sl.ufpr.br/hddtemp/$(HDDTEMP_SOURCE)

$(D)/hddtemp: $(D)/bootstrap $(ARCHIVE)/$(HDDTEMP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/hddtemp-$(HDDTEMP_VER)
	$(UNTAR)/$(HDDTEMP_SOURCE)
	$(CHDIR)/hddtemp-$(HDDTEMP_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--datadir=/.remove \
			--with-db_path=/var/hddtemp.db \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		install -d $(TARGET_DIR)/var/tuxbox/config
		install -m 644 $(MACHINE_COMMON_DIR)/hddtemp.db $(TARGET_DIR)/var
	$(REMOVE)/hddtemp-$(HDDTEMP_VER)
	$(TOUCH)
