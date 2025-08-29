#
# set up build environment for other makefiles
#
# -----------------------------------------------------------------------------

#SHELL := $(SHELL) -x

CONFIG_SITE =
export CONFIG_SITE

LD_LIBRARY_PATH =
export LD_LIBRARY_PATH

# -----------------------------------------------------------------------------

# set up default parallelism
# nproc + 1 results in faster compile times
PARALLEL_JOBS := $(shell echo $$((1 + `getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1`)))
override MAKE = make $(if $(findstring j,$(filter-out --%,$(MAKEFLAGS))),,-j$(PARALLEL_JOBS)) $(SILENT_OPT)

MAKEFLAGS             += --no-print-directory

# -----------------------------------------------------------------------------

# default platform...
BASE_DIR             := $(shell pwd)
ARCHIVE              ?= $(BASE_DIR)/Archive
TOOLS_DIR             = $(BASE_DIR)/build_tools
BUILD_TMP             = $(BASE_DIR)/build_tmp
SOURCE_DIR            = $(BASE_DIR)/build_source
RELEASE_IMAGE_DIR     = $(BASE_DIR)/release_image

-include $(BASE_DIR)/config

# for local extensions
-include $(BASE_DIR)/config.local


GITHUB                = https://github.com

GIT_NAME             ?= TangoCash
GIT_NAME_TOOLS       ?= TangoCash

# default config...
BOXARCH              ?= arm
BOXTYPE              ?= hd51
CI_ENABLED           ?= 1
FFMPEG_VERSION       ?= 6.1
OPTIMIZATIONS        ?= size
BS_GCC_VER           ?= 10.5.0
IMAGE                ?= neutrino
FLAVOUR              ?= TANGOSEVO
EXTERNAL_LCD         ?= both
LAYOUT               ?= multi
BUSYBOX_SNAPSHOT     ?= 0
#
ITYPE                ?= usb

TARGET_DIR            = $(BASE_DIR)/build_sysroot
HOST_DIR              = $(BASE_DIR)/build_host
RELEASE_DIR_CLEANUP   = $(BASE_DIR)/build_release
ifeq ($(LAYOUT), multi)
RELEASE_DIR           = $(BASE_DIR)/build_release/linuxrootfs1
else
RELEASE_DIR           = $(BASE_DIR)/build_release
endif

CUSTOM_DIR            = $(BASE_DIR)/custom
OWN_BUILD             = $(BASE_DIR)/own_build
PATCHES               = $(BASE_DIR)/patches
HELPERS_DIR           = $(BASE_DIR)/helpers
SKEL_ROOT             = $(BASE_DIR)/root
D                     = $(BASE_DIR)/.deps

MACHINE_DIR           = $(BASE_DIR)/machine/$(BOXTYPE)
MACHINE_PATCHES       = $(MACHINE_DIR)/patches
MACHINE_FILES         = $(MACHINE_DIR)/files
MACHINE_COMMON_DIR    = $(BASE_DIR)/machine/common/files

ifneq ($(SUDOPASSWD),)
SUDOCMD               = fakeroot
else
SUDOCMD               = echo $(SUDOPASSWD) | sudo -S
endif


MAINTAINER           ?= $(shell whoami)
CCACHE                = /usr/bin/ccache

BUILD                ?= $(shell /usr/share/libtool/config.guess 2>/dev/null || /usr/share/libtool/config/config.guess 2>/dev/null || /usr/share/misc/config.guess 2>/dev/null)

ifeq ($(BOXARCH), arm)
CCACHE_DIR            = $(BASE_DIR)/.ccache-bs-arm
export CCACHE_DIR
TARGET               ?= arm-cortex-linux-gnueabihf
TARGET_MARCH_CFLAGS   = -march=armv7ve -mtune=cortex-a15 -mfpu=neon-vfpv4 -mfloat-abi=hard
endif

ifeq ($(BOXARCH), aarch64)
CCACHE_DIR            = $(BASE_DIR)/.ccache-bs-aarch64
export CCACHE_DIR
TARGET               ?= aarch64-unknown-linux-gnu
TARGET_MARCH_CFLAGS   =
CORTEX_STRINGS        =
endif

ifeq ($(OPTIMIZATIONS), size)
TARGET_O_CFLAGS       = -Os
TARGET_EXTRA_CFLAGS   = -ffunction-sections -fdata-sections
TARGET_EXTRA_LDFLAGS  = -Wl,--gc-sections
endif
ifeq ($(OPTIMIZATIONS), normal)
TARGET_O_CFLAGS       = -O2
TARGET_EXTRA_CFLAGS   =
TARGET_EXTRA_LDFLAGS  =
endif
ifeq ($(OPTIMIZATIONS), kerneldebug)
TARGET_O_CFLAGS       = -O2
TARGET_EXTRA_CFLAGS   =
TARGET_EXTRA_LDFLAGS  =
endif
ifeq ($(OPTIMIZATIONS), debug)
TARGET_O_CFLAGS       = -O0 -g -ggdb
TARGET_EXTRA_CFLAGS   =
TARGET_EXTRA_LDFLAGS  =
endif

ifeq ($(BS_GCC_VER), 9.5.0)
CROSSTOOL_GCC_VER = gcc-9.5.0
endif

ifeq ($(BS_GCC_VER), 10.5.0)
CROSSTOOL_GCC_VER = gcc-10.5.0
endif

ifeq ($(BS_GCC_VER), 11.4.0)
CROSSTOOL_GCC_VER = gcc-11.4.0
NEED_TIRPC             = 1
endif

ifeq ($(BS_GCC_VER), 12.3.0)
CROSSTOOL_GCC_VER = gcc-12.3.0
NEED_TIRPC             = 1
endif

ifeq ($(BS_GCC_VER), 13.2.0)
CROSSTOOL_GCC_VER = gcc-13.2.0
NEED_TIRPC             = 1
endif

CROSS_BASE            = $(BASE_DIR)/cross
include               $(BASE_DIR)/machine/$(BOXTYPE)/linux-environment.mk
CROSS_DIR             = $(CROSS_BASE)/$(CROSSTOOL_GCC_VER)-$(BOXARCH)-kernel-$(KERNEL_VER)

# -----------------------------------------------------------------------------

TARGET_BASE_LIB_DIR   = $(TARGET_DIR)/lib
TARGET_LIB_DIR        = $(TARGET_DIR)/usr/lib
TARGET_INCLUDE_DIR    = $(TARGET_DIR)/usr/include
TARGET_SHARE_DIR      = $(TARGET_DIR)/usr/share

TARGET_CFLAGS         = -pipe $(TARGET_O_CFLAGS) $(TARGET_MARCH_CFLAGS) $(TARGET_EXTRA_CFLAGS) -I$(TARGET_INCLUDE_DIR)
ifeq ($(BS_GCC_VER), $(filter $(BS_GCC_VER), 10.5.0 11.4.0 12.3.0 13.2.0))
TARGET_CFLAGS        +=-fcommon
endif
TARGET_CPPFLAGS       = $(TARGET_CFLAGS)
TARGET_CXXFLAGS       = $(TARGET_CFLAGS)
TARGET_LDFLAGS        = -Wl,-rpath -Wl,/usr/lib -Wl,-rpath-link -Wl,$(TARGET_LIB_DIR) -L$(TARGET_LIB_DIR) -L$(TARGET_DIR)/lib $(TARGET_EXTRA_LDFLAGS)
LD_FLAGS              = $(TARGET_LDFLAGS)
PKG_CONFIG            = $(HOST_DIR)/bin/$(TARGET)-pkg-config
PKG_CONFIG_PATH       = $(TARGET_LIB_DIR)/pkgconfig

VPATH                 = $(D)

PATH                 := $(HOST_DIR)/bin:$(CROSS_DIR)/bin:$(PATH)

TERM_RED             := \033[00;31m
TERM_RED_BOLD        := \033[01;31m
TERM_GREEN           := \033[00;32m
TERM_GREEN_BOLD      := \033[01;32m
TERM_YELLOW          := \033[00;33m
TERM_YELLOW_BOLD     := \033[01;33m
TERM_NORMAL          := \033[0m

AUTOCONF_VER          = $(shell autoconf --version | head -1 | awk '{print $$4}')
AUTOCONF_NEW          = $(shell echo $(AUTOCONF_VER)\>=2.70 | bc )

# -----------------------------------------------------------------------------

# To put more focus on warnings, be less verbose as default
# Use 'make V=1' to see the full commands
ifeq ("$(origin V)", "command line")
VERBOSE               = $(V)
endif

# If VERBOSE equals 0 then the above command will be hidden.
# If VERBOSE equals 1 then the above command is displayed.
ifeq ($(VERBOSE),1)
SILENT_PATCH          =
SILENT_OPT            =
SILENT                =
DOWNLOAD_SILENT_OPT   =
else
SILENT_PATCH          = -s
SILENT_OPT           := >/dev/null 2>&1
SILENT                = @
DOWNLOAD_SILENT_OPT   = -o /dev/null
MAKEFLAGS            += --silent
endif

# -----------------------------------------------------------------------------

# certificates
CA_BUNDLE             = ca-certificates.crt
CA_BUNDLE_DIR         = /etc/ssl/certs

# -----------------------------------------------------------------------------

# helper-"functions"
REWRITE_LIBTOOLX       = sed -i "s,^libdir=.*,libdir='$(TARGET_LIB_DIR)'," $(TARGET_LIB_DIR)
REWRITE_LIBTOOLDEPX    = sed -i -e "s,\(^dependency_libs='\| \|-L\|^dependency_libs='\)/usr/lib,\ $(TARGET_LIB_DIR),g" $(TARGET_LIB_DIR)
REWRITE_PKGCONFX       = sed -i "s,^prefix=.*,prefix='$(TARGET_DIR)/usr',"

# unpack tarballs, clean up
UNTAR                 = $(SILENT)tar -C $(BUILD_TMP) -xf $(ARCHIVE)
REMOVE                = $(SILENT)rm -rf $(BUILD_TMP)

# download tarballs into archive directory
DOWNLOAD = wget --progress=bar:force --no-check-certificate $(DOWNLOAD_SILENT_OPT) -t6 -T20 -c -P $(ARCHIVE)

CD                    = set -e; cd
CHDIR                 = $(CD) $(BUILD_TMP)
MKDIR                 = mkdir -p $(BUILD_TMP)
STRIP                 = $(TARGET)-strip
DEPMOD                = $(HOST_DIR)/bin/depmod

DATE                  = $(shell date '+%d.%m.%Y-%H.%M')
# -----------------------------------------------------------------------------

split_deps_dir=$(subst ., ,$(1))
DEPS_DIR              = $(subst $(D)/,,$@)
PKG_NAME              = $(word 1,$(call split_deps_dir,$(DEPS_DIR)))
PKG_NAME_HELPER       = $(shell echo $(PKG_NAME) | sed 's/.*/\U&/')
PKG_VER_HELPER        = A$($(PKG_NAME_HELPER)_VER)A
PKG_VER               = $($(PKG_NAME_HELPER)_VER)
PKG_DIR               = $(BUILD_TMP)/$(PKG_NAME)
PKG_PATCH             = $(BASE_DIR)/packages/$(basename $(@F))/patches
PKG_FILES             = $(BASE_DIR)/packages/$(basename $(@F))/files

START_BUILD           = @$(call draw_line,$(PKG_NAME),6); \
                        echo; \
                        if [ $(PKG_VER_HELPER) == "AA" ]; then \
                            echo -e "Start build of $(TERM_GREEN_BOLD)$(PKG_NAME)$(TERM_NORMAL)"; \
                        else \
                            echo -e "Start build of $(TERM_GREEN_BOLD)$(PKG_NAME) $(PKG_VER)$(TERM_NORMAL)"; \
                        fi

TOUCH                 = @touch $@; \
                        if [ $(PKG_VER_HELPER) == "AA" ]; then \
                            echo -e "Build of $(TERM_GREEN_BOLD)$(PKG_NAME)$(TERM_NORMAL) completed"; \
                        else \
                            echo -e "Build of $(TERM_GREEN_BOLD)$(PKG_NAME) $(PKG_VER)$(TERM_NORMAL) completed"; \
                        fi; \
                        echo ; \
                        $(call draw_line,$(PKG_NAME),2); \
                        echo

TUXBOX_CUSTOMIZE = [ -x $(CUSTOM_DIR)/$(notdir $@)-local.sh ] && \
	KERNEL_VER=$(KERNEL_VER) && \
	BOXTYPE=$(BOXTYPE) && \
	$(CUSTOM_DIR)/$(notdir $@)-local.sh \
	$(RELEASE_DIR) \
	$(TARGET_DIR) \
	$(BASE_DIR) \
	$(SOURCE_DIR) \
	$(BOXTYPE) \
	$(FLAVOUR) \
	$(RELEASE_IMAGE_DIR) \
	$(LAYOUT) \
	$(NEUTRINO) \
	$(LIBSTB_HAL) \
	|| true

#
#
#
CONFIGURE_OPTS = \
	--build=$(BUILD) \
	--host=$(TARGET) \

BUILDENV := \
	CC=$(TARGET)-gcc \
	CXX=$(TARGET)-g++ \
	LD=$(TARGET)-ld \
	NM=$(TARGET)-nm \
	AR=$(TARGET)-ar \
	AS=$(TARGET)-as \
	RANLIB=$(TARGET)-ranlib \
	STRIP=$(TARGET)-strip \
	OBJCOPY=$(TARGET)-objcopy \
	OBJDUMP=$(TARGET)-objdump \
	LN_S="ln -s" \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)"

CONFIGURE = \
	test -f ./configure || ./autogen.sh $(SILENT_OPT) && \
	$(BUILDENV) \
	./configure $(SILENT_OPT) $(CONFIGURE_OPTS)

CONFIGURE_TOOLS = \
	./autogen.sh $(SILENT_OPT) && \
	$(BUILDENV) \
	./configure $(SILENT_OPT) $(CONFIGURE_OPTS)

MAKE_OPTS := \
	CC=$(TARGET)-gcc \
	CXX=$(TARGET)-g++ \
	LD=$(TARGET)-ld \
	NM=$(TARGET)-nm \
	AR=$(TARGET)-ar \
	AS=$(TARGET)-as \
	RANLIB=$(TARGET)-ranlib \
	STRIP=$(TARGET)-strip \
	OBJCOPY=$(TARGET)-objcopy \
	OBJDUMP=$(TARGET)-objdump \
	LN_S="ln -s" \
	ARCH=sh \
	CROSS_COMPILE=$(TARGET)-

CMAKE_OPTS := \
	-DBUILD_SHARED_LIBS=ON \
	-DENABLE_STATIC=OFF \
	-DCMAKE_BUILD_TYPE="Release" \
	-DCMAKE_SYSTEM_NAME="Linux" \
	-DCMAKE_SYSTEM_PROCESSOR="arm" \
	-DCMAKE_INSTALL_DOCDIR=/.remove \
	-DCMAKE_INSTALL_MANDIR=/.remove \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_INSTALL_DEFAULT_LIBDIR=lib \
	-DCMAKE_INCLUDE_PATH="$(TARGET_INCLUDE_DIR)" \
	-DCMAKE_PREFIX_PATH=$(TARGET_DIR)/usr \
	-DCMAKE_C_COMPILER=$(TARGET)-gcc \
	-DCMAKE_CXX_COMPILER=$(TARGET)-g++ \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS)" \
	-DCMAKE_LINKER="$(TARGET)-ld" \
	-DCMAKE_AR="$(TARGET)-ar" \
	-DCMAKE_NM="$(TARGET)-nm" \
	-DCMAKE_OBJDUMP="$(TARGET)-objdump" \
	-DCMAKE_RANLIB="$(TARGET)-ranlib" \
	-DCMAKE_STRIP="$(TARGET)-strip"

CMAKE := \
	rm -f CMakeCache.txt; \
	cmake $(SILENT_OPT) --no-warn-unused-cli $(CMAKE_OPTS)

