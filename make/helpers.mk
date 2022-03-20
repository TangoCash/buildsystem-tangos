#
# makefile to keep buildsystem helpers
#
# -----------------------------------------------------------------------------

# Buildsystem Revision
BUILDSYSTEM_REV=$(shell cd $(BASE_DIR); git log | grep "^commit" | wc -l)
# Neutrino Revision
NEUTRINO_REV=$(shell cd $(SOURCE_DIR)/$(NEUTRINO); git log | grep "^commit" | wc -l)
# libstb-hal Revision
LIBSTB_HAL_REV=$(shell cd $(SOURCE_DIR)/$(LIBSTB_HAL); git log | grep "^commit" | wc -l)

# -----------------------------------------------------------------------------

# apply patch sets
PATCH  = patch -Np1 $(SILENT_PATCH) -i $(PATCHES)

define apply_patches
    l=`echo $(2)`; test -z $$l && l=1; \
    for i in $(1); do \
        if [ -d $$i ]; then \
            for p in $$i/*; do \
                if [ $${p:0:1} == "/" ]; then \
                    echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $${p##*/}"; patch -p$$l $(SILENT_PATCH) -i $$p; \
                else \
                    echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $${p##*/}"; patch -p$$l $(SILENT_PATCH) -i $(PATCHES)/$$p; \
                fi; \
            done; \
        else \
            if [ $${i:0:1} == "/" ]; then \
                echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $${i##*/}"; patch -p$$l $(SILENT_PATCH) -i $$i; \
            else \
                echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $${i##*/}"; patch -p$$l $(SILENT_PATCH) -i $(PATCHES)/$$i; \
            fi; \
        fi; \
    done; \
    if [ $(PKG_VER_HELPER) == "AA" ]; then \
        echo -e "Patching $(TERM_GREEN_BOLD)$(PKG_NAME)$(TERM_NORMAL) completed"; \
    else \
        echo -e "Patching $(TERM_GREEN_BOLD)$(PKG_NAME) $(PKG_VER)$(TERM_NORMAL) completed"; \
    fi; \
    echo
endef

# -----------------------------------------------------------------------------
define update_git
	set -e; \
	b=`echo $(2)`; test -z $$b || b=`echo -b $(2)`; \
	if [ -d $(ARCHIVE)/$(PKG_NAME).git ]; \
	then \
		cd $(ARCHIVE)/$(PKG_NAME).git; git pull; \
	else \
		cd $(ARCHIVE); git clone $$b $(1) $(PKG_NAME).git; \
	fi; \
	cp -ra $(ARCHIVE)/$(PKG_NAME).git $(BUILD_TMP)/$(PKG_NAME);
endef
# -----------------------------------------------------------------------------

# rewrite libtool libraries
REWRITE_LIBTOOL_RULES = "s,^libdir=.*,libdir='$(1)',; \
			 s,\(^dependency_libs='\| \|-L\|^dependency_libs='\)/lib,\ $(1),g"

REWRITE_LIBTOOL_TAG = rewritten=1

define rewrite_libtool # (libdir)
	echo -e "Fixing libtool files in $(subst $(TARGET_DIR)/,,$(1))"
	$(SILENT)( \
	for la in $$(find $(1) -name "*.la" -type f); do \
		if ! grep -q "$(REWRITE_LIBTOOL_TAG)" $${la}; then \
			sed -i -e $(REWRITE_LIBTOOL_RULES) $${la}; \
			echo -e "\n# Adapted to buildsystem\n$(REWRITE_LIBTOOL_TAG)" >> $${la}; \
		fi; \
	done; \
	);
endef

# rewrite libtool libraries automatically
REWRITE_LIBTOOL = $(foreach libdir,$(TARGET_BASE_LIB_DIR) $(TARGET_LIB_DIR),\
			$(call rewrite_libtool,$(libdir)))

# -----------------------------------------------------------------------------
REWRITE_PKGCONF_RULES = "s,^prefix=.*,prefix='$(TARGET_DIR)/usr',g"

REWRITE_PKGCONF_TAG = rewritten=1

define rewrite_pkgconf # (pkg config path)
	echo -e "Fixing pkg config files in $(subst $(TARGET_DIR)/,,$(1))"
	$(SILENT)( \
	for pc in $$(find $(1) -name "*.pc" -type f); do \
		if ! grep -q "$(REWRITE_PKGCONF_TAG)" $${pc}; then \
			sed -i -e $(REWRITE_PKGCONF_RULES) $${pc}; \
			echo -e "\n# Adapted to buildsystem\n# $(REWRITE_PKGCONF_TAG)" >> $${pc}; \
		fi; \
	done; \
	);
endef

REWRITE_PKGCONF = $(call rewrite_pkgconf,$(PKG_CONFIG_PATH))
# -----------------------------------------------------------------------------
#
# $(1) = title
# $(2) = color
#	0 - Black
#	1 - Red
#	2 - Green
#	3 - Yellow
#	4 - Blue
#	5 - Magenta
#	6 - Cyan
#	7 - White
# $(3) = left, center, right
#
define draw_line
	printf '%.0s~' {1..$(shell tput cols)}; \
	if test "$(1)"; then \
		cols=$(shell tput cols); \
		length=$(shell echo $(1) | awk '{print length}'); \
		case "$(3)" in \
			*right)  let indent="length + 1" ;; \
			*left) let indent="cols" ;; \
			*center|*) let indent="cols - (cols - length) / 2" ;; \
		esac; \
		tput cub $$indent; \
		test "$(2)" && printf $$(tput setaf $(2)); \
		printf '$(1)'; \
		test "$(2)" && printf $$(tput sgr0); \
	fi; \
	echo
endef

#
# patch helper
#
neutrino%-patch \
libstb-hal%-patch:
	( cd $(SOURCE_DIR) && diff -Nur --exclude-from=$(HELPERS_DIR)/diff-exclude $(subst -patch,,$@).org $(subst -patch,,$@) > $(BASE_DIR)/$(subst -patch,-`date +%d.%m.%Y_%H:%M`.patch,$@) ; [ $$? -eq 1 ] )

neutrino%-diff \
libstb-hal%-diff:
	( cd $(SOURCE_DIR) && diff -Nur --exclude-from=$(HELPERS_DIR)/diff-exclude $(subst -diff,,$@).dev $(subst -diff,,$@) > $(BASE_DIR)/$(subst -diff,-`date +%d.%m.%Y_%H:%M`.patch,$@) ; [ $$? -eq 1 ] )

# keeping all patches together in one file
# uncomment if needed
#
# Neutrino Max
NEUTRINO_MAX_PATCHES =
LIBSTB_HAL_MAX_PATCHES =

# Neutrino DDT
NEUTRINO_DDT_PATCHES =
LIBSTB_HAL_DDT_PATCHES =

# Neutrino NI
NEUTRINO_NI_PATCHES =
LIBSTB_HAL_NI_PATCHES =

# Neutrino Tango
NEUTRINO_TANGOS_PATCHES =
LIBSTB_HAL_TANGOS_PATCHES =

# Neutrino Tuxbox
NEUTRINO_TUX_PATCHES =
LIBSTB_HAL_TUX_PATCHES =

# Neutrino HD2
NEUTRINO_HD2_PATCHES +=
NEUTRINO_HD2_PLUGINS_PATCHES +=
