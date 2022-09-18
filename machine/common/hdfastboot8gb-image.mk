#
# flashimage
#
FLASH_IMAGE_NAME = disk
FLASH_BOOT_IMAGE = bootoptions.img
FLASH_IMAGE_LINK = $(FLASH_IMAGE_NAME).ext4

FLASH_BOOTOPTIONS_PARTITION_SIZE = 32768
FLASH_IMAGE_ROOTFS_SIZE = 1024M

FLASH_BOOTARGS_SRC = $(BOXTYPE)-bootargs-$(FLASH_BOOTARGS_DATE).zip
FLASH_PARTITONS_SRC = $(BOXTYPE)-partitions-$(FLASH_PARTITONS_DATE).zip
FLASH_RECOVERY_SRC = $(BOXTYPE)-recovery-$(FLASH_RECOVERY_DATE).zip

$(ARCHIVE)/$(FLASH_BOOTARGS_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/$(MACHINE)/$(FLASH_BOOTARGS_SRC)

$(ARCHIVE)/$(FLASH_PARTITONS_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/$(MACHINE)/$(FLASH_PARTITONS_SRC)

$(ARCHIVE)/$(FLASH_RECOVERY_SRC):
	$(DOWNLOAD) http://source.mynonpublic.com/$(MACHINE)/$(FLASH_RECOVERY_SRC)

flash-image-$(BOXTYPE)-multi-disk: $(ARCHIVE)/$(FLASH_BOOTARGS_SRC) $(ARCHIVE)/$(FLASH_PARTITONS_SRC) $(ARCHIVE)/$(FLASH_RECOVERY_SRC)
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
	echo "$(BOXTYPE)_$(DATE)_RECOVERY" > $(FLASH_BUILD_TMP)/$(BOXTYPE)/recoveryversion
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
	echo boot-recovery > $(FLASH_BUILD_TMP)/$(BOXTYPE)/misc-boot.img
	cp $(RELEASE_DIR)/boot/uImage $(FLASH_BUILD_TMP)/$(BOXTYPE)/uImage
	rm -rf $(FLASH_BUILD_TMP)/STARTUP*
	rm -rf $(FLASH_BUILD_TMP)/*.txt
	rm -rf $(FLASH_BUILD_TMP)/$(BOXTYPE)/*.txt
	rm -rf $(FLASH_BUILD_TMP)/$(FLASH_IMAGE_LINK)
	echo "To access the recovery image press immediately by power-up the frontpanel button or hold down a remote button key untill the display says boot" > $(FLASH_BUILD_TMP)/$(BOXTYPE)/recovery.txt
	cd $(FLASH_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multiroot_$(ITYPE)_$(DATE)_recovery_emmc.zip *
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)

flash-image-$(BOXTYPE)-multi-rootfs:
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(BOXTYPE)
	cp $(RELEASE_DIR)/boot/uImage $(FLASH_BUILD_TMP)/$(BOXTYPE)/uImage
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar --exclude=uImage* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar
	echo "$(BOXTYPE)_$(FLAVOUR)_multiroot_$(ITYPE)_$(DATE)" > $(FLASH_BUILD_TMP)/$(BOXTYPE)/imageversion
	echo "$(BOXTYPE)_$(FLAVOUR)_multiroot_$(ITYPE)_$(DATE)_emmc.zip" > $(FLASH_BUILD_TMP)/unforce_$(BOXTYPE).txt; \
	echo "Rename the unforce_$(BOXTYPE).txt to force_$(BOXTYPE).txt and move it to the root of your usb-stick" > $(FLASH_BUILD_TMP)/force_$(BOXTYPE)_READ.ME; \
	echo "When you enter the recovery menu then it will force to install the image $$(cat $(FLASH_BUILD_TMP)/$(BOXTYPE)/imageversion).zip in the image-slot1" >> $(FLASH_BUILD_TMP)/force_$(BOXTYPE)_READ.ME; \
	cd $(FLASH_BUILD_TMP) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multiroot_$(ITYPE)_$(DATE)_mmc.zip unforce_$(BOXTYPE).txt force_$(BOXTYPE)_READ.ME $(BOXTYPE)/rootfs.tar.bz2 $(BOXTYPE)/uImage $(BOXTYPE)/imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)

flash-image-$(BOXTYPE)-online:
	rm -rf $(FLASH_BUILD_TMP) || true
	mkdir -p $(FLASH_BUILD_TMP)/$(BOXTYPE)
	cp $(RELEASE_DIR)/boot/uImage $(FLASH_BUILD_TMP)/$(BOXTYPE)/uImage
	cd $(RELEASE_DIR); \
	tar -cvf $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar --exclude=uImage* . > /dev/null 2>&1; \
	bzip2 $(FLASH_BUILD_TMP)/$(BOXTYPE)/rootfs.tar
	echo $(BOXTYPE)_$(FLAVOUR)_$(ITYPE)_$(DATE) > $(FLASH_BUILD_TMP)/$(BOXTYPE)/imageversion
	cd $(FLASH_BUILD_TMP)/$(BOXTYPE) && \
	tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multiroot_$(ITYPE)_$(DATE).tgz rootfs.tar.bz2 uImage imageversion
	# cleanup
	rm -rf $(FLASH_BUILD_TMP)
