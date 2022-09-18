#
# ofgwrite
#
OFGWRITE_GIT = $(GITHUB)/MaxWiesel/ofgwrite-max.git
OFGWRITE_PATCH = ofgwrite.patch

$(D)/ofgwrite: $(D)/bootstrap
	$(START_BUILD)
	$(REMOVE)/$(PKG_NAME)
	$(call update_git, $(OFGWRITE_GIT))
	$(CHDIR)/$(PKG_NAME); \
		$(call apply_patches,$(PKG_PATCH)); \
		$(BUILDENV) \
		$(MAKE)
	install -m 755 $(PKG_DIR)/ofgwrite_bin $(TARGET_DIR)/usr/bin
	install -m 755 $(PKG_DIR)/ofgwrite_caller $(TARGET_DIR)/usr/bin
	install -m 755 $(PKG_DIR)/ofgwrite $(TARGET_DIR)/usr/bin
	$(REMOVE)/$(PKG_NAME)
	$(TOUCH)

