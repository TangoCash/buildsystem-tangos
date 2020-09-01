#
# flashimage
#

### armbox hd61

flashimage: $(D)/host_atools $(D)/neutrino
	$(MAKE) flash-image-hd61-multi-disk flash-image-hd61-multi-rootfs
	$(TUXBOX_CUSTOMIZE)
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

ofgimage: $(D)/host_atools $(D)/neutrino
	$(MAKE) ITYPE=ofg flash-image-hd61-multi-rootfs
	$(TUXBOX_CUSTOMIZE)
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

online-image: $(D)/host_atools $(D)/neutrino
	$(MAKE) ITYPE=online flash-image-hd61-online
	$(TUXBOX_CUSTOMIZE)
	@$(call draw_line,);
	@$(call draw_line,Build of $@ for $(BOXTYPE) successfully completed.,2);
	@$(call draw_line,);

flash-clean:
	echo ""

# general
FLASH_IMAGE_NAME = disk
FLASH_BOOT_IMAGE = bootoptions.img
FLASH_IMAGE_LINK = $(FLASH_IMAGE_NAME).ext4
FLASH_BUILD_TMP = $(BUILD_TMP)/image-build

FLASH_BOOTOPTIONS_PARTITION_SIZE = 32768
FLASH_IMAGE_ROOTFS_SIZE = 1024M

FLASH_BOOTARGS_DATE = 20190605
FLASH_BOOTARGS_SRC = hd61-bootargs-$(FLASH_BOOTARGS_DATE).zip
FLASH_PARTITONS_DATE = 20190719
FLASH_PARTITONS_SRC = hd61-partitions-$(FLASH_PARTITONS_DATE).zip
FLASH_RECOVERY_DATE = 20190719
FLASH_RECOVERY_SRC = hd61-recovery-$(FLASH_RECOVERY_DATE).zip

$(ARCHIVE)/$(FLASH_BOOTARGS_SRC):
	$(DOWNLOAD) http://downloads.mutant-digital.net/hd61/$(FLASH_BOOTARGS_SRC)

$(ARCHIVE)/$(FLASH_PARTITONS_SRC):
	$(DOWNLOAD) http://downloads.mutant-digital.net/hd61/$(FLASH_PARTITONS_SRC)

$(ARCHIVE)/$(FLASH_RECOVERY_SRC):
	$(DOWNLOAD) http://downloads.mutant-digital.net/hd61/$(FLASH_RECOVERY_SRC)

flash-image-hd61-multi-disk: $(ARCHIVE)/$(FLASH_BOOTARGS_SRC) $(ARCHIVE)/$(FLASH_PARTITONS_SRC) $(ARCHIVE)/$(FLASH_RECOVERY_SRC)
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(BOXTYPE)
	unzip -o $(ARCHIVE)/$(FLASH_BOOTARGS_SRC) -d $(FLASH_BUILD_TMP)
	unzip -o $(ARCHIVE)/$(FLASH_PARTITONS_SRC) -d $(FLASH_BUILD_TMP)
	unzip -o $(ARCHIVE)/$(FLASH_RECOVERY_SRC) -d $(FLASH_BUILD_TMP)
	install -m 0755 $(FLASH_BUILD_TMP)/bootargs-8gb.bin $(RELEASE_DIR)/usr/share/bootargs.bin
	install -m 0755 $(FLASH_BUILD_TMP)/fastboot.bin $(RELEASE_DIR)/usr/share/fastboot.bin
	if [ -e $(RELEASE_DIR)/boot/logo.img ]; then \
		cp -rf $(RELEASE_DIR)/boot/logo.img $(FLASH_BUILD_TMP)/$(BOXTYPE); \
	fi
	echo "$(BOXTYPE)_multi_usb_$(shell date '+%d.%m.%Y-%H.%M')_recovery_emmc" > $(FLASH_BUILD_TMP)/$(BOXTYPE)/imageversion
	$(HOST_DIR)/bin/make_ext4fs -l $(FLASH_IMAGE_ROOTFS_SIZE) $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_LINK) $(RELEASE_DIR)/..
	$(HOST_DIR)/bin/ext2simg -zv $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_LINK) $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.fastboot.gz
	dd if=/dev/zero of=$(FLASH_BUILD_TMP)/$(BOXTYPE)/$(FLASH_BOOT_IMAGE) bs=1024 count=$(FLASH_BOOTOPTIONS_PARTITION_SIZE)
	mkfs.msdos -S 512 $(FLASH_BUILD_TMP)/$(BOXTYPE)/$(FLASH_BOOT_IMAGE)
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); mmc read 0 0x1000000 0x3BD000 0x8000; bootm 0x1000000; run bootcmd_fallback" > $(FLASH_BUILD_TMP)/STARTUP
	echo "bootargs=root=/dev/mmcblk0p23 rootsubdir=linuxrootfs1 rootfstype=ext4 kernel=/dev/mmcblk0p19" >> $(FLASH_BUILD_TMP)/STARTUP
	echo "bootcmd=setenv vfd_msg andr;setenv bootargs \$$(bootargs) \$$(bootargs_common); run bootcmd_android; run bootcmd_fallback" > $(FLASH_BUILD_TMP)/STARTUP_ANDROID
	echo "bootargs=androidboot.selinux=disable androidboot.serialno=0123456789" >> $(FLASH_BUILD_TMP)/STARTUP_ANDROID
	echo "bootcmd=setenv vfd_msg andr;setenv bootargs \$$(bootargs) \$$(bootargs_common); run bootcmd_android; run bootcmd_fallback" > $(FLASH_BUILD_TMP)/STARTUP_ANDROID_DISABLE_LINUXSE
	echo "bootargs=androidboot.selinux=disable androidboot.serialno=0123456789" >> $(FLASH_BUILD_TMP)/STARTUP_ANDROID_DISABLE_LINUXSE
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); mmc read 0 0x1000000 0x3BD000 0x8000; bootm 0x1000000; run bootcmd_fallback" > $(FLASH_BUILD_TMP)/STARTUP_LINUX_1
	echo "bootargs=root=/dev/mmcblk0p23 rootsubdir=linuxrootfs1 rootfstype=ext4 kernel=/dev/mmcblk0p19" >> $(FLASH_BUILD_TMP)/STARTUP_LINUX_1
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); mmc read 0 0x1000000 0x3C5000 0x8000; bootm 0x1000000; run bootcmd_fallback" > $(FLASH_BUILD_TMP)/STARTUP_LINUX_2
	echo "bootargs=root=/dev/mmcblk0p23 rootsubdir=linuxrootfs2 rootfstype=ext4 kernel=/dev/mmcblk0p20" >> $(FLASH_BUILD_TMP)/STARTUP_LINUX_2
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); mmc read 0 0x1000000 0x3CD000 0x8000; bootm 0x1000000; run bootcmd_fallback" > $(FLASH_BUILD_TMP)/STARTUP_LINUX_3
	echo "bootargs=root=/dev/mmcblk0p23 rootsubdir=linuxrootfs3 rootfstype=ext4 kernel=/dev/mmcblk0p21" >> $(FLASH_BUILD_TMP)/STARTUP_LINUX_3
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); mmc read 0 0x1000000 0x3D5000 0x8000; bootm 0x1000000; run bootcmd_fallback" > $(FLASH_BUILD_TMP)/STARTUP_LINUX_4
	echo "bootargs=root=/dev/mmcblk0p23 rootsubdir=linuxrootfs4 rootfstype=ext4 kernel=/dev/mmcblk0p22" >> $(FLASH_BUILD_TMP)/STARTUP_LINUX_4
	echo "bootcmd=setenv bootargs \$$(bootargs_common); mmc read 0 0x1000000 0x1000 0x9000; bootm 0x1000000" > $(FLASH_BUILD_TMP)/STARTUP_RECOVERY
	echo "bootcmd=setenv bootargs \$$(bootargs_common); mmc read 0 0x1000000 0x1000 0x9000; bootm 0x1000000" > $(FLASH_BUILD_TMP)/STARTUP_ONCE
	echo "imageurl https://raw.githubusercontent.com/oe-alliance/bootmenu/master/$(BOXTYPE)/images" > $(FLASH_BUILD_TMP)/bootmenu.conf
	echo "# " >> $(FLASH_BUILD_TMP)/bootmenu.conf
	echo "iface eth0" >> $(FLASH_BUILD_TMP)/bootmenu.conf
	echo "dhcp yes" >> $(FLASH_BUILD_TMP)/bootmenu.conf
	echo "# " >> $(FLASH_BUILD_TMP)/bootmenu.conf
	echo "# for static config leave out 'dhcp yes' and add the following settings:" >> $(FLASH_BUILD_TMP)/bootmenu.conf
	echo "# " >> $(FLASH_BUILD_TMP)/bootmenu.conf
	echo "#ip 192.168.178.10" >> $(FLASH_BUILD_TMP)/bootmenu.conf
	echo "#netmask 255.255.255.0" >> $(FLASH_BUILD_TMP)/bootmenu.conf
	echo "#gateway 192.168.178.1" >> $(FLASH_BUILD_TMP)/bootmenu.conf
	echo "#dns 192.168.178.1" >> $(FLASH_BUILD_TMP)/bootmenu.conf
	mcopy -i $(FLASH_BUILD_TMP)/$(BOXTYPE)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP ::
	mcopy -i $(FLASH_BUILD_TMP)/$(BOXTYPE)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_ANDROID ::
	mcopy -i $(FLASH_BUILD_TMP)/$(BOXTYPE)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_ANDROID_DISABLE_LINUXSE ::
	mcopy -i $(FLASH_BUILD_TMP)/$(BOXTYPE)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_LINUX_1 ::
	mcopy -i $(FLASH_BUILD_TMP)/$(BOXTYPE)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_LINUX_2 ::
	mcopy -i $(FLASH_BUILD_TMP)/$(BOXTYPE)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_LINUX_3 ::
	mcopy -i $(FLASH_BUILD_TMP)/$(BOXTYPE)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_LINUX_4 ::
	mcopy -i $(FLASH_BUILD_TMP)/$(BOXTYPE)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/STARTUP_RECOVERY ::
	mcopy -i $(FLASH_BUILD_TMP)/$(BOXTYPE)/$(FLASH_BOOT_IMAGE) -v $(FLASH_BUILD_TMP)/bootmenu.conf ::
	mv $(FLASH_BUILD_TMP)/bootargs-8gb.bin $(FLASH_BUILD_TMP)/bootargs.bin
	mv $(FLASH_BUILD_TMP)/$(BOXTYPE)/bootargs-8gb.bin $(FLASH_BUILD_TMP)/$(BOXTYPE)/bootargs.bin
	cp $(RELEASE_DIR)/boot/uImage $(FLASH_BUILD_TMP)/$(BOXTYPE)/uImage
	rm -rf $(FLASH_BUILD_TMP)/STARTUP*
	rm -rf $(FLASH_BUILD_TMP)/*.txt
	rm -rf $(FLASH_BUILD_TMP)/$(BOXTYPE)/*.txt
	rm -rf $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_LINK)
	echo "To access the recovery image press immediately by power-up the frontpanel button or hold down a remote button key untill the display says boot" > $(FLASH_BUILD_TMP)/$(BOXTYPE)/recovery.txt
	cd $(FLASH_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$$(cat $(FLASH_BUILD_TMP)/$(BOXTYPE)/imageversion).zip *
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)

flash-image-hd61-multi-rootfs:
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(BOXTYPE)
	cp $(RELEASE_DIR)/boot/uImage $(FLASH_BUILD_TMP)/$(BOXTYPE)/uImage
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar --exclude=uImage* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar
	echo "$(BOXTYPE)_multi_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M')_emmc" > $(FLASH_BUILD_TMP)/$(BOXTYPE)/imageversion
	echo "$$(cat $(FLASH_BUILD_TMP)/$(BOXTYPE)/imageversion).zip" > $(FLASH_BUILD_TMP)/unforce_$(BOXTYPE).txt; \
	echo "Rename the unforce_$(BOXTYPE).txt to force_$(BOXTYPE).txt and move it to the root of your usb-stick" > $(FLASH_BUILD_TMP)/force_$(BOXTYPE)_READ.ME; \
	echo "When you enter the recovery menu then it will force to install the image $$(cat $(FLASH_BUILD_TMP)/$(BOXTYPE)/imageversion).zip in the image-slot1" >> $(FLASH_BUILD_TMP)/force_$(BOXTYPE)_READ.ME; \
	cd $(FLASH_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$$(cat $(FLASH_BUILD_TMP)/$(BOXTYPE)/imageversion).zip unforce_$(BOXTYPE).txt force_$(BOXTYPE)_READ.ME $(BOXTYPE)/rootfs.tar.bz2 $(BOXTYPE)/uImage $(BOXTYPE)/imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)

flash-image-hd61-online:
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(BOXTYPE)
	cp $(RELEASE_DIR)/boot/uImage $(FLASH_BUILD_TMP)/$(BOXTYPE)/uImage
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar --exclude=uImage* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(FLASH_BUILD_TMP)/$(BOXTYPE)/imageversion
	cd $(FLASH_BUILD_TMP)/$(BOXTYPE) && \
	tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_multi_$(ITYPE)_$(shell date '+%d.%m.%Y-%H.%M').tgz rootfs.tar.bz2 uImage imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)
