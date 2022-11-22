# makefile to build NEUTRINO

# -----------------------------------------------------------------------------
N_CONFIG_KEYS ?=

OMDB_API_KEY ?=
ifneq ($(strip $(OMDB_API_KEY)),)
N_CONFIG_KEYS += \
	--with-omdb-api-key="$(OMDB_API_KEY)" \
	--disable-omdb-key-manage
endif

TMDB_DEV_KEY ?=
ifneq ($(strip $(TMDB_DEV_KEY)),)
N_CONFIG_KEYS += \
	--with-tmdb-dev-key="$(TMDB_DEV_KEY)" \
	--disable-tmdb-key-manage
endif

YOUTUBE_DEV_KEY ?=
ifneq ($(strip $(YOUTUBE_DEV_KEY)),)
N_CONFIG_KEYS += \
	--with-youtube-dev-key="$(YOUTUBE_DEV_KEY)" \
	--disable-youtube-key-manage
endif

SHOUTCAST_DEV_KEY ?=
ifneq ($(strip $(SHOUTCAST_DEV_KEY)),)
N_CONFIG_KEYS += \
	--with-shoutcast-dev-key="$(SHOUTCAST_DEV_KEY)" \
	--disable-shoutcast-key-manage
endif

WEATHER_DEV_KEY ?=
ifneq ($(strip $(WEATHER_DEV_KEY)),)
N_CONFIG_KEYS += \
	--with-weather-dev-key="$(WEATHER_DEV_KEY)" \
	--disable-weather-key-manage
endif

# -----------------------------------------------------------------------------

COMMON_DEPS  = $(D)/bootstrap
COMMON_DEPS += $(KERNEL)
COMMON_DEPS += $(D)/system-tools
COMMON_DEPS += $(D)/ncurses
COMMON_DEPS += $(D)/libcurl
COMMON_DEPS += $(D)/libpng
COMMON_DEPS += $(D)/libjpeg
COMMON_DEPS += $(D)/giflib
COMMON_DEPS += $(D)/alsa_utils
COMMON_DEPS += $(D)/freetype
COMMON_DEPS += $(D)/zlib
COMMON_DEPS += $(D)/ffmpeg
COMMON_DEPS += $(D)/libopenthreads
COMMON_DEPS += $(D)/libfribidi
COMMON_DEPS += $(D)/lua
COMMON_DEPS += $(D)/luaexpat
COMMON_DEPS += $(D)/luacurl
COMMON_DEPS += $(D)/luasocket
COMMON_DEPS += $(D)/luafeedparser
COMMON_DEPS += $(D)/luasoap
COMMON_DEPS += $(D)/luajson
COMMON_DEPS += $(D)/ntfs_3g
COMMON_DEPS += $(D)/gptfdisk
COMMON_DEPS += $(D)/mc
COMMON_DEPS += $(D)/samba
COMMON_DEPS += $(D)/rsync
COMMON_DEPS += $(D)/links
COMMON_DEPS += $(D)/dropbearmulti
COMMON_DEPS += $(D)/djmount
#COMMON_DEPS +=  $(D)/minidlna
#COMMON_DEPS +=  $(D)/minisatip
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), sf8008 sf8008m ustym4kpro))
	COMMON_DEPS += $(D)/libsdl
endif

# -----------------------------------------------------------------------------

LIBSTB_HAL_DEPS = $(COMMON_DEPS)

# -----------------------------------------------------------------------------

NEUTRINO_DEPS  = $(COMMON_DEPS)
NEUTRINO_DEPS += $(D)/libsigc
NEUTRINO_DEPS += $(D)/libdvbsi
NEUTRINO_DEPS += $(D)/libusb
NEUTRINO_DEPS += $(D)/pugixml

NEUTRINO_DEPS += $(D)/neutrino-plugins
NEUTRINO_DEPS += $(D)/neutrino-plugin-scripts-lua
NEUTRINO_DEPS += $(D)/neutrino-plugin-mediathek
NEUTRINO_DEPS += $(D)/neutrino-plugin-xupnpd
NEUTRINO_DEPS += $(D)/neutrino-plugin-channellogos
NEUTRINO_DEPS += $(D)/neutrino-plugin-iptvplayer
NEUTRINO_DEPS += $(D)/neutrino-plugin-settings-update
NEUTRINO_DEPS += $(D)/neutrino-plugin-webtv-radio
NEUTRINO_DEPS += $(D)/neutrino-plugin-custom
NEUTRINO_DEPS += $(LOCAL_NEUTRINO_DEPS)
NEUTRINO_DEPS += $(LOCAL_NEUTRINO_PLUGINS)

NEUTRINO_DEPS += $(D)/mediainfo
NEUTRINO_DEPS += $(D)/netsurf

#NEUTRINO_DEPS += $(D)/gdb
#NEUTRINO_DEPS += $(D)/host-gdb

N_CONFIG_OPTS  = $(LOCAL_NEUTRINO_BUILD_OPTIONS)

ifeq ($(IMAGE), neutrino-wifi)
NEUTRINO_DEPS += $(D)/wpa_supplicant
NEUTRINO_DEPS += $(D)/wireless_tools
endif

N_CFLAGS       = -Wall -W -Wshadow -pipe -Os
N_CFLAGS      += -D__KERNEL_STRICT_NAMES
N_CFLAGS      += -D__STDC_FORMAT_MACROS
N_CFLAGS      += -D__STDC_CONSTANT_MACROS
N_CFLAGS      += -fno-strict-aliasing
N_CFLAGS      += -funsigned-char
N_CFLAGS      += -ffunction-sections
N_CFLAGS      += -fdata-sections
N_CFLAGS      += -Wno-psabi
#N_CFLAGS      += -Wno-deprecated-declarations
#N_CFLAGS      += -DCPU_FREQ
N_CFLAGS      += $(LOCAL_NEUTRINO_CFLAGS)

N_CPPFLAGS     = -I$(TARGET_INCLUDE_DIR)
N_CPPFLAGS    += -ffunction-sections -fdata-sections
N_CPPFLAGS    += -Wno-cast-function-type

ifeq ($(BOXARCH), arm)
N_CPPFLAGS    += -I$(CROSS_DIR)/$(TARGET)/sys-root/usr/include
endif

LH_CONFIG_OPTS = $(LOCAL_LIBHAL_BUILD_OPTIONS)

ifeq ($(FLAVOUR), $(filter $(FLAVOUR), NI TUXBOX))
N_CONFIG_OPTS += --with-boxtype=armbox
N_CONFIG_OPTS += --with-boxmodel=$(BOXTYPE)
LH_CONFIG_OPTS += --with-boxtype=armbox
LH_CONFIG_OPTS += --with-boxmodel=$(BOXTYPE)
else
N_CONFIG_OPTS += --with-boxtype=$(BOXTYPE)
LH_CONFIG_OPTS += --with-boxtype=$(BOXTYPE)
endif

ifeq ($(CI_ENABLED), 1)
N_CONFIG_OPTS += --enable-ci
endif

N_CONFIG_OPTS += --enable-ffmpegdec
N_CONFIG_OPTS += --enable-freesatepg
N_CONFIG_OPTS += --enable-fribidi
#N_CONFIG_OPTS += --enable-dynamicdemux
#N_CONFIG_OPTS += --enable-reschange
N_CONFIG_OPTS += --disable-upnp
#N_CONFIG_OPTS += --disable-pip
#N_CONFIG_OPTS += --disable-webif
#N_CONFIG_OPTS += --disable-tangos

ifeq ($(IMAGE), neutrino-wifi)
N_CONFIG_OPTS += --enable-wifi
endif

ifeq ($(BOXTYPE), osmio4kplus)
N_CONFIG_OPTS += --enable-lcd
endif

ifeq  ($(FLAVOUR), TANGOS)
N_CONFIG_OPTS += --with-default-theme=TangoCash
endif

N_CONFIG_OPTS += \
	--with-libdir=/usr/lib \
	--with-datadir=/usr/share/tuxbox \
	--with-fontdir=/usr/share/fonts \
	--with-fontdir_var=/var/tuxbox/fonts \
	--with-configdir=/var/tuxbox/config \
	--with-gamesdir=/var/tuxbox/games \
	--with-iconsdir=/usr/share/tuxbox/neutrino/icons \
	--with-iconsdir_var=/var/tuxbox/icons \
	--with-localedir=/usr/share/tuxbox/neutrino/locale \
	--with-localedir_var=/var/tuxbox/locale \
	--with-plugindir=/usr/share/tuxbox/neutrino/plugins \
	--with-plugindir_var=/var/tuxbox/plugins \
	--with-lcd4liconsdir_var=/var/tuxbox/lcd/icons \
	--with-luaplugindir=/var/tuxbox/plugins \
	--with-public_httpddir=/var/tuxbox/httpd \
	--with-private_httpddir=/usr/share/tuxbox/neutrino/httpd \
	--with-themesdir=/usr/share/tuxbox/neutrino/themes \
	--with-themesdir_var=/var/tuxbox/themes \
	--with-webtvdir=/usr/share/tuxbox/neutrino/webtv \
	--with-webtvdir_var=/var/tuxbox/webtv \
	--with-webradiodir=/usr/share/tuxbox/neutrino/webradio \
	--with-webradiodir_var=/var/tuxbox/webradio \
	--with-controldir=/usr/share/tuxbox/neutrino/control \
	--with-controldir_var=/var/tuxbox/control \
	--with-zapitdir=/var/tuxbox/config/zapit

ifeq ($(EXTERNAL_LCD), graphlcd)
N_CONFIG_OPTS += --enable-graphlcd
NEUTRINO_DEPS += $(D)/graphlcd
endif

ifeq ($(EXTERNAL_LCD), lcd4linux)
N_CONFIG_OPTS += --enable-lcd4linux
NEUTRINO_DEPS += $(D)/lcd4linux
NEUTRINO_DEPS += $(D)/neutrino-plugin-l4l-skins
endif

ifeq ($(EXTERNAL_LCD), both)
N_CONFIG_OPTS += --enable-graphlcd
N_CONFIG_OPTS += --enable-lcd4linux
NEUTRINO_DEPS += $(D)/graphlcd
NEUTRINO_DEPS += $(D)/lcd4linux
NEUTRINO_DEPS += $(D)/neutrino-plugin-l4l-skins
endif
# -----------------------------------------------------------------------------

ifeq ($(MEDIAFW), gstreamer)
NEUTRINO_DEPS  += $(D)/gst_plugins_dvbmediasink
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-audio-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-video-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs glib-2.0)
LH_CONFIG_OPTS += --enable-gstreamer_10=yes
endif

# -----------------------------------------------------------------------------

N_OBJDIR = $(BUILD_TMP)/$(NEUTRINO)
LH_OBJDIR = $(BUILD_TMP)/$(LIBSTB_HAL)

ifeq ($(FLAVOUR), MAX)
GIT_URL     ?= $(GITHUB)/MaxWiesel
NEUTRINO     = neutrino-max
LIBSTB_HAL   = libstb-hal-max
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = $(NEUTRINO_MAX_PATCHES)
HAL_PATCHES  = $(LIBSTB_HAL_MAX_PATCHES)
else ifeq  ($(FLAVOUR), NI)
GIT_URL     ?= $(GITHUB)/neutrino-images
NEUTRINO     = ni-neutrino
LIBSTB_HAL   = ni-libstb-hal
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = neutrino-ni-exit-codes.patch
NMP_PATCHES += $(NEUTRINO_NI_PATCHES)
HAL_PATCHES  = $(LIBSTB_HAL_NI_PATCHES)
else ifeq  ($(FLAVOUR), TANGOS)
GIT_URL     ?= $(GITHUB)/TangoCash
NEUTRINO     = neutrino-tangos
LIBSTB_HAL   = libstb-hal-tangos
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = $(NEUTRINO_TANGOS_PATCHES)
HAL_PATCHES  = $(LIBSTB_HAL_TANGOS_PATCHES)
else ifeq  ($(FLAVOUR), TANGOSEVO)
GIT_URL     ?= $(GITHUB)/TangoCash
NEUTRINO     = neutrino-tangos
NMP_BRANCH  ?= evo
NMP_PATCHES  = $(NEUTRINO_TANGOSEVO_PATCHES)
else ifeq  ($(FLAVOUR), DDT)
GIT_URL     ?= $(GITHUB)/Duckbox-Developers
NEUTRINO     = neutrino-ddt
LIBSTB_HAL   = libstb-hal-ddt
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = neutrino-ddt-plugindir-fix.patch
NMP_PATCHES  = $(NEUTRINO_DDT_PATCHES)
HAL_PATCHES  = $(LIBSTB_HAL_DDT_PATCHES)
else ifeq  ($(FLAVOUR), TUXBOX)
GIT_URL     ?= $(GITHUB)/tuxbox-neutrino
NEUTRINO     = gui-neutrino
LIBSTB_HAL   = library-stb-hal
NMP_BRANCH  ?= master
HAL_BRANCH  ?= mpx
NMP_PATCHES  = $(NEUTRINO_TUX_PATCHES)
HAL_PATCHES  = $(LIBSTB_HAL_TUX_PATCHES)
else ifeq ($(FLAVOUR), HD2)
NEUTRINO     = neutrino-hd2
endif

ifneq  ($(FLAVOUR), TANGOSEVO)
LIBDEP = $(D)/libstb-hal
endif

# -----------------------------------------------------------------------------

.version: $(TARGET_DIR)/.version
$(TARGET_DIR)/.version:
	echo "distro=$(FLAVOUR)" > $@
	echo "imagename=`sed -n 's/\#define PACKAGE_NAME "//p' $(N_OBJDIR)/config.h | sed 's/"//'`" >> $@
#	echo "imageversion=`sed -n 's/\#define PACKAGE_VERSION "//p' $(N_OBJDIR)/config.h | sed 's/"//'`" >> $@
	echo "imageversion=rev$(shell expr $(BUILDSYSTEM_REV) + $(LIBSTB_HAL_REV) + $(NEUTRINO_REV))" >> $@
	echo "homepage=$(GIT_URL)" >> $@
	echo "creator=$(MAINTAINER)" >> $@
	echo "docs=$(GIT_URL)" >> $@
	echo "forum=$(GIT_URL)/$(NEUTRINO)" >> $@
	echo "version=0200`date +%Y%m%d%H%M`" >> $@
	echo "builddate="`date` >> $@
	echo "git=BS-rev$(BUILDSYSTEM_REV)_HAL-rev$(LIBSTB_HAL_REV)_$(FLAVOUR)-rev$(NEUTRINO_REV)" >> $@
	echo "imagedir=$(BOXTYPE)" >> $@

# -----------------------------------------------------------------------------

e2-multiboot:
	touch $(TARGET_DIR)/usr/bin/enigma2
	#
	#echo -e "$(FLAVOUR) `sed -n 's/\#define PACKAGE_VERSION "//p' $(N_OBJDIR)/config.h | sed 's/"//'` \\\n \\\l\n" > $(TARGET_DIR)/etc/issue
	echo -e "$(FLAVOUR) rev$(shell expr $(BUILDSYSTEM_REV) + $(LIBSTB_HAL_REV) + $(NEUTRINO_REV)) \\\n \\\l\n" >> $(TARGET_DIR)/etc/issue
	#
	touch $(TARGET_DIR)/var/lib/opkg/status
	#
	cp -a $(TARGET_DIR)/.version $(TARGET_DIR)/etc/image-version

# -----------------------------------------------------------------------------

version.h: $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
$(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h:
	@rm -f $@
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(SOURCE_DIR)/$(LIBSTB_HAL); then \
		echo '#define VCS "BS-rev$(BUILDSYSTEM_REV)_HAL-rev$(LIBSTB_HAL_REV)_$(FLAVOUR)-rev$(NEUTRINO_REV)"' >> $@; \
	fi
	if [ "$(FLAVOUR)" = "HD2" ]; then \
		echo '#define GIT "$(BUILDSYSTEM_REV)"' >> $@; \
	fi

# -----------------------------------------------------------------------------

$(D)/libstb-hal.do_prepare: | $(LIBSTB_HAL_DEPS)
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL)
	rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL).org
	rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL).dev
	rm -rf $(LH_OBJDIR)
	test -d $(SOURCE_DIR) || mkdir -p $(SOURCE_DIR)
	[ -d "$(ARCHIVE)/$(LIBSTB_HAL).git" ] && \
	(cd $(ARCHIVE)/$(LIBSTB_HAL).git; git pull;); \
	[ -d "$(ARCHIVE)/$(LIBSTB_HAL).git" ] || \
	git clone $(GIT_URL)/$(LIBSTB_HAL).git $(ARCHIVE)/$(LIBSTB_HAL).git; \
	cp -ra $(ARCHIVE)/$(LIBSTB_HAL).git $(SOURCE_DIR)/$(LIBSTB_HAL);\
	(cd $(SOURCE_DIR)/$(LIBSTB_HAL); git checkout $(HAL_BRANCH);); \
	cp -ra $(SOURCE_DIR)/$(LIBSTB_HAL) $(SOURCE_DIR)/$(LIBSTB_HAL).org
	set -e; cd $(SOURCE_DIR)/$(LIBSTB_HAL); \
		$(call apply_patches, $(HAL_PATCHES))
	cp -ra $(SOURCE_DIR)/$(LIBSTB_HAL) $(SOURCE_DIR)/$(LIBSTB_HAL).dev
	@touch $@

$(D)/libstb-hal.config.status:
	rm -rf $(LH_OBJDIR)
	test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR)
	cd $(LH_OBJDIR); \
		$(SOURCE_DIR)/$(LIBSTB_HAL)/autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/$(LIBSTB_HAL)/configure $(SILENT_OPT) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix=/usr \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared=no \
			\
			--with-target=cdk \
			--with-targetprefix=/usr \
			$(LH_CONFIG_OPTS) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
#	@touch $@

$(D)/libstb-hal.do_compile: $(D)/libstb-hal.config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(LH_OBJDIR) DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/libstb-hal: $(D)/libstb-hal.do_prepare $(D)/libstb-hal.do_compile
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(TOUCH)

libstb-hal-clean:
	rm -f $(D)/libstb-hal
	rm -f $(D)/libstb-hal.config.status
	cd $(LH_OBJDIR); \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-distclean:
	rm -rf $(LH_OBJDIR)
	rm -f $(D)/libstb-hal
	rm -f $(D)/libstb-hal.do_*
	rm -f $(D)/libstb-hal.config.status

# -----------------------------------------------------------------------------

$(D)/neutrino.do_prepare: | $(NEUTRINO_DEPS) $(LIBDEP)
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/$(NEUTRINO)
	rm -rf $(SOURCE_DIR)/$(NEUTRINO).org
	rm -rf $(SOURCE_DIR)/$(NEUTRINO).dev
	rm -rf $(N_OBJDIR)
	[ -d "$(ARCHIVE)/$(NEUTRINO).git" ] && \
	(cd $(ARCHIVE)/$(NEUTRINO).git; git pull;); \
	[ -d "$(ARCHIVE)/$(NEUTRINO).git" ] || \
	git clone $(GIT_URL)/$(NEUTRINO).git $(ARCHIVE)/$(NEUTRINO).git; \
	cp -ra $(ARCHIVE)/$(NEUTRINO).git $(SOURCE_DIR)/$(NEUTRINO); \
	(cd $(SOURCE_DIR)/$(NEUTRINO); git checkout $(NMP_BRANCH);); \
	cp -ra $(SOURCE_DIR)/$(NEUTRINO) $(SOURCE_DIR)/$(NEUTRINO).org
	set -e; cd $(SOURCE_DIR)/$(NEUTRINO); \
		$(call apply_patches, $(NMP_PATCHES))
	cp -ra $(SOURCE_DIR)/$(NEUTRINO) $(SOURCE_DIR)/$(NEUTRINO).dev
	@touch $@

$(D)/neutrino.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR)
	cd $(N_OBJDIR); \
		$(SOURCE_DIR)/$(NEUTRINO)/autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/$(NEUTRINO)/configure $(SILENT_OPT) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix=/usr \
			--enable-maintainer-mode \
			--enable-silent-rules \
			\
			--enable-giflib \
			--enable-lua \
			--enable-pugixml \
			\
			$(N_CONFIG_KEYS) \
			\
			$(N_CONFIG_OPTS) \
			\
			--with-tremor \
			--with-stb-hal-includes=$(SOURCE_DIR)/$(LIBSTB_HAL)/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
		+make $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
#	@touch $@

$(D)/neutrino.do_compile: $(D)/neutrino.config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/neutrino: $(D)/neutrino.do_prepare $(D)/neutrino.do_compile
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	make .version
	make e2-multiboot
	$(TOUCH)
	$(HOST_DIR)/bin/qrencode -o $(TARGET_DIR)/usr/share/tuxbox/neutrino/icons/qr.png "$(GIT_URL)" -m 1 -s 5
	make neutrino-release
	$(TUXBOX_CUSTOMIZE)

neutrino-clean:
	rm -f $(D)/neutrino
	rm -f $(D)/neutrino.config.status
	rm -f $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino
	rm -f $(D)/neutrino.do_*
	rm -f $(D)/neutrino.config.status

# -----------------------------------------------------------------------------
#
# neutrino-hd2
#

NHD2_DEPS  = $(COMMON_DEPS)
NHD2_DEPS += $(D)/libid3tag
NHD2_DEPS += $(D)/libmad
NHD2_DEPS += $(D)/libvorbisidec
NHD2_DEPS += $(D)/flac
NHD2_DEPS += $(D)/python

NHD2_OPTS += --enable-lua
NHD2_OPTS += --enable-python
NHD2_OPTS += --enable-ci
NHD2_OPTS += --with-datadir=/usr/share/tuxbox
NHD2_OPTS += --with-fontdir=/usr/share/fonts
NHD2_OPTS += --with-configdir=/var/tuxbox/config
NHD2_OPTS += --with-gamesdir=/var/tuxbox/games
NHD2_OPTS += --with-plugindir=/var/tuxbox/plugins
NHD2_OPTS += --with-isocodesdir=/usr/share/iso-codes

NEUTRINO_HD2_PATCHES = \
	neutrino-hd2-python.patch \
	neutrino-hd2-fix-compile.patch

$(D)/neutrino-hd2.do_prepare: | $(NHD2_DEPS)
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/$(NEUTRINO)
	rm -rf $(SOURCE_DIR)/$(NEUTRINO).org
	rm -rf $(SOURCE_DIR)/$(NEUTRINO).dev
	rm -rf $(N_OBJDIR)
	[ -d "$(ARCHIVE)/neutrino-hd2.git" ] && \
	(cd $(ARCHIVE)/neutrino-hd2.git; git pull;); \
	[ -d "$(ARCHIVE)/neutrino-hd2.git" ] || \
	git clone $(GITHUB)/mohousch/neutrinohd2.git $(ARCHIVE)/neutrino-hd2.git; \
	cp -ra $(ARCHIVE)/neutrino-hd2.git/nhd2-exp $(SOURCE_DIR)/neutrino-hd2; \
	cp -ra $(SOURCE_DIR)/neutrino-hd2 $(SOURCE_DIR)/neutrino-hd2.org
	set -e; cd $(SOURCE_DIR)/neutrino-hd2; \
		$(call apply_patches, $(NEUTRINO_HD2_PATCHES))
	cp -ra $(SOURCE_DIR)/neutrino-hd2 $(SOURCE_DIR)/neutrino-hd2.dev
	@touch $@

$(D)/neutrino-hd2.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR)
	cd $(N_OBJDIR); \
		$(SOURCE_DIR)/$(NEUTRINO)/autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/$(NEUTRINO)/configure $(SILENT_OPT) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--enable-silent-rules \
			--with-boxtype=$(BOXTYPE) \
			--prefix=/usr \
			$(NHD2_OPTS) \
			git_dir=$(ARCHIVE)/neutrino-hd2.git \
			LUA=$(HOST_DIR)/bin/lua \
			PY_PATH=$(TARGET_DIR)/usr \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(N_CPPFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)"
		+make $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
	@touch $@

$(D)/neutrino-hd2.do_compile: $(D)/neutrino-hd2.config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/neutrino-hd2: $(D)/neutrino-hd2.do_prepare $(D)/neutrino-hd2.do_compile
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	make .version
	make python-install
	make e2-multiboot
	$(TOUCH)
	make neutrino-hd2-plugins
	make neutrino-release
	$(TUXBOX_CUSTOMIZE)

neutrino-hd2-clean:
	rm -f $(D)/neutrino-hd2
	rm -f $(D)/neutrino-hd2.config.status
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-hd2-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-hd2
	rm -f $(D)/neutrino-hd2.do_*
	rm -f $(D)/neutrino-hd2.config.status

# -----------------------------------------------------------------------------

PHONY += $(TARGET_DIR)/.version
PHONY += $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
