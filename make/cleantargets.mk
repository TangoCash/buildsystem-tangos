#
# makefile for clean targets and archive
#
# -----------------------------------------------------------------------------

%-clean:
	( cd $(D) && find . -name $(subst -clean,,$@) -delete )

depsclean:
	( cd $(D) && find . ! -name "*\.*" -delete )

clean: depsclean
	@echo -e "$(TERM_YELLOW)---> cleaning system build directories and files .. $(TERM_NORMAL)"
	@-$(MAKE) kernel-clean
	@-$(MAKE) tools-clean
	@-$(MAKE) driver-clean
	@-rm -rf $(TARGET_DIR)
	@-rm -rf $(HOST_DIR)
	@-rm -rf $(RELEASE_DIR_CLEANUP)
	@-rm -rf $(D)/kernel
	@-rm -rf $(D)/*.do_compile
	@-rm -rf $(D)/*.config.status
	@echo -e "$(TERM_YELLOW)done\n$(TERM_NORMAL)"

distclean:
	@echo -e "$(TERM_YELLOW)---> cleaning system build directories and files .. $(TERM_NORMAL)"
	@-$(MAKE) tools-clean
	@-$(MAKE) driver-clean
	@-rm -rf $(TARGET_DIR)
	@-rm -rf $(HOST_DIR)
	@-rm -rf $(RELEASE_DIR_CLEANUP)
	@-rm -rf $(BUILD_TMP)
	@-rm -rf $(SOURCE_DIR)
	@-rm -rf $(BASE_DIR)/build_*
	@-rm -rf $(D)
	@test -d $(D) || mkdir $(D)
	@echo -e "$(TERM_YELLOW)done\n$(TERM_NORMAL)"

# -----------------------------------------------------------------------------

PHONY += %-clean
PHONY += depsclean
PHONY += clean
PHONY += distclean
