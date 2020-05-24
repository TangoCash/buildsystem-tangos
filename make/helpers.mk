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
                    echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$p"; patch -p$$l $(SILENT_PATCH) -i $$p; \
                else \
                    echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$p"; patch -p$$l $(SILENT_PATCH) -i $(PATCHES)/$$p; \
                fi; \
            done; \
        else \
            if [ $${i:0:1} == "/" ]; then \
                echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$i"; patch -p$$l $(SILENT_PATCH) -i $$i; \
            else \
                echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$i"; patch -p$$l $(SILENT_PATCH) -i $(PATCHES)/$$i; \
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
	( cd $(SOURCE_DIR) && diff -Nur --exclude-from=$(HELPERS_DIR)/diff-exclude $(subst -patch,,$@).org $(subst -patch,,$@) > $(BASE_DIR)/$(subst -patch,.patch,$@) ; [ $$? -eq 1 ] )

# keeping all patches together in one file
# uncomment if needed
#
# Neutrino MP DDT
NEUTRINO_MAX_PATCHES =
LIBSTB_HAL_MAX_PATCHES =

# Neutrino MP DDT
NEUTRINO_DDT_PATCHES =
LIBSTB_HAL_DDT_PATCHES =

# Neutrino MP NI
NEUTRINO_NI_PATCHES =
LIBSTB_HAL_NI_PATCHES =

# Neutrino MP Tango
NEUTRINO_TANGOS_PATCHES =
LIBSTB_HAL_TANGOS_PATCHES =

# Neutrino HD2
NEUTRINO_HD2_PATCHES +=
NEUTRINO_HD2_PLUGINS_PATCHES +=
