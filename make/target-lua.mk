#
# lua
#
LUA_VER = 5.2.4
LUA_VER_SHORT = 5.2
LUA_SOURCE = lua-$(LUA_VER).tar.gz

LUAPOSIX_VER = 31
LUAPOSIX_SOURCE = luaposix-git-$(LUAPOSIX_VER).tar.bz2
LUAPOSIX_URL = $(GITHUB)/luaposix/luaposix.git
LUAPOSIX_PATCH = lua-$(LUA_VER)-luaposix-$(LUAPOSIX_VER).patch

$(ARCHIVE)/$(LUA_SOURCE):
	$(DOWNLOAD) https://www.lua.org/ftp/$(LUA_SOURCE)

$(ARCHIVE)/$(LUAPOSIX_SOURCE):
	$(HELPERS_DIR)/get-git-archive.sh $(LUAPOSIX_URL) release-v$(LUAPOSIX_VER) $(notdir $@) $(ARCHIVE)

$(D)/lua: $(D)/bootstrap $(D)/host_lua $(D)/ncurses $(ARCHIVE)/$(LUAPOSIX_SOURCE) $(ARCHIVE)/$(LUA_SOURCE)
	$(START_BUILD)
	$(REMOVE)/lua-$(LUA_VER)
	mkdir -p $(TARGET_SHARE_DIR)/lua/$(LUA_VER_SHORT)
	$(UNTAR)/$(LUA_SOURCE)
	$(CHDIR)/lua-$(LUA_VER); \
		$(call apply_patches, $(LUAPOSIX_PATCH)); \
		tar xf $(ARCHIVE)/$(LUAPOSIX_SOURCE); \
		cd luaposix-git-$(LUAPOSIX_VER)/ext; cp posix/posix.c include/lua52compat.h ../../src/; cd ../..; \
		cd luaposix-git-$(LUAPOSIX_VER)/lib; cp *.lua $(TARGET_SHARE_DIR)/lua/$(LUA_VER_SHORT); cd ../..; \
		sed -i 's/<config.h>/"config.h"/' src/posix.c; \
		sed -i '/^#define/d' src/lua52compat.h; \
		sed -i 's|man/man1|/.remove|' Makefile; \
		$(MAKE) linux CC=$(TARGET)-gcc CPPFLAGS="$(TARGET_CPPFLAGS) -fPIC" LDFLAGS="-L$(TARGET_LIB_DIR)" BUILDMODE=dynamic PKG_VERSION=$(LUA_VER); \
		$(MAKE) install INSTALL_TOP=$(TARGET_DIR)/usr INSTALL_MAN=$(TARGET_DIR)/.remove
	cd $(TARGET_DIR)/usr && rm bin/lua bin/luac
	$(REMOVE)/lua-$(LUA_VER)
	$(TOUCH)

#
# luaexpat
#
LUAEXPAT_VER = 33744ae
LUAEXPAT_SOURCE = luaexpat-git-$(LUAEXPAT_VER).tar.bz2
LUAEXPAT_URL = $(GITHUB)/lunarmodules/luaexpat.git
LUAEXPAT_PATCH = luaexpat-git-$(LUAEXPAT_VER).patch

$(ARCHIVE)/$(LUAEXPAT_SOURCE):
	$(HELPERS_DIR)/get-git-archive.sh $(LUAEXPAT_URL) $(LUAEXPAT_VER) $(notdir $@) $(ARCHIVE)

$(D)/luaexpat: $(D)/bootstrap $(D)/lua $(D)/expat $(ARCHIVE)/$(LUAEXPAT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/luaexpat-$(LUAEXPAT_VER)
	$(UNTAR)/$(LUAEXPAT_SOURCE)
	$(CHDIR)/luaexpat-git-$(LUAEXPAT_VER); \
		$(call apply_patches, $(LUAEXPAT_PATCH)); \
		$(MAKE) CC=$(TARGET)-gcc LDFLAGS="-L$(TARGET_LIB_DIR)" PREFIX=$(TARGET_DIR)/usr; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)/usr
	$(REMOVE)/luaexpat-git-$(LUAEXPAT_VER)
	$(TOUCH)

#
# luafeedparser
#
LUAFEEDPARSER_VER = 9b284bc
LUAFEEDPARSER_SOURCE = luafeedparser-git-$(LUAFEEDPARSER_VER).tar.bz2
LUAFEEDPARSER_URL = $(GITHUB)/slact/lua-feedparser.git

$(ARCHIVE)/$(LUAFEEDPARSER_SOURCE):
	$(HELPERS_DIR)/get-git-archive.sh $(LUAFEEDPARSER_URL) $(LUAFEEDPARSER_VER) $(notdir $@) $(ARCHIVE)

$(D)/luafeedparser: $(D)/bootstrap $(D)/lua $(D)/luasocket $(D)/luaexpat $(ARCHIVE)/$(LUAFEEDPARSER_SOURCE)
	$(START_BUILD)
	$(REMOVE)/luafeedparser-git-$(LUAFEEDPARSER_VER)
	$(UNTAR)/$(LUAFEEDPARSER_SOURCE)
	$(CHDIR)/luafeedparser-git-$(LUAFEEDPARSER_VER); \
		sed -i -e "s/^PREFIX.*//" -e "s/^LUA_DIR.*//" Makefile ; \
		$(BUILDENV) $(MAKE) install  LUA_DIR=$(TARGET_SHARE_DIR)/lua/$(LUA_VER_SHORT)
	$(REMOVE)/luafeedparser-git-$(LUAFEEDPARSER_VER)
	$(TOUCH)

#
# luajson
#
$(ARCHIVE)/json.lua:
	$(DOWNLOAD) $(GITHUB)/swiboe/swiboe/raw/master/term_gui/json.lua

$(D)/luajson: $(D)/bootstrap $(D)/lua $(ARCHIVE)/json.lua
	$(START_BUILD)
	cp $(ARCHIVE)/json.lua $(TARGET_SHARE_DIR)/lua/$(LUA_VER_SHORT)/json.lua
	$(TOUCH)

#
# luacurl
#
LUACURL_VER = e0b1d2ee
LUACURL_SOURCE = luacurl-git-$(LUACURL_VER).tar.bz2
LUACURL_URL = $(GITHUB)/Lua-cURL/Lua-cURLv3.git
LUACURL_PATCH = lua-curl-Makefile.patch

$(ARCHIVE)/$(LUACURL_SOURCE):
	$(HELPERS_DIR)/get-git-archive.sh $(LUACURL_URL) $(LUACURL_VER) $(notdir $@) $(ARCHIVE)

$(D)/luacurl: $(D)/bootstrap $(D)/libcurl $(D)/lua $(ARCHIVE)/$(LUACURL_SOURCE)
	$(START_BUILD)
	$(REMOVE)/luacurl-git-$(LUACURL_VER)
	$(UNTAR)/$(LUACURL_SOURCE)
	$(CHDIR)/luacurl-git-$(LUACURL_VER); \
		$(call apply_patches, $(LUACURL_PATCH)); \
		$(MAKE) CC=$(TARGET)-gcc LDFLAGS="-L$(TARGET_LIB_DIR)" \
			LIBDIR=$(TARGET_LIB_DIR) \
			LUA_INC=$(TARGET_INCLUDE_DIR) \
			CURL_LIBS="-lcurl"; \
		$(MAKE) install DESTDIR=$(TARGET_DIR) LUA_CMOD=/usr/lib/lua/$(LUA_VER_SHORT) LUA_LMOD=/usr/share/lua/$(LUA_VER_SHORT)
	$(REMOVE)/luacurl-git-$(LUACURL_VER)
	$(TOUCH)

#
# luasocket
#
LUASOCKET_VER = 5a17f79
LUASOCKET_SOURCE = luasocket-git-$(LUASOCKET_VER).tar.bz2
LUASOCKET_URL = $(GITHUB)/diegonehab/luasocket.git

$(ARCHIVE)/$(LUASOCKET_SOURCE):
	$(HELPERS_DIR)/get-git-archive.sh $(LUASOCKET_URL) $(LUASOCKET_VER) $(notdir $@) $(ARCHIVE)

$(D)/luasocket: $(D)/bootstrap $(D)/lua $(ARCHIVE)/$(LUASOCKET_SOURCE)
	$(START_BUILD)
	$(REMOVE)/luasocket-git-$(LUASOCKET_VER)
	$(UNTAR)/$(LUASOCKET_SOURCE)
	$(CHDIR)/luasocket-git-$(LUASOCKET_VER); \
		sed -i -e "s@LD_linux=gcc@LD_LINUX=$(TARGET)-gcc@" -e "s@CC_linux=gcc@CC_LINUX=$(TARGET)-gcc -L$(TARGET_LIB_DIR)@" -e "s@DESTDIR?=@DESTDIR?=$(TARGET_DIR)/usr@" src/makefile; \
		$(MAKE) CC=$(TARGET)-gcc LD=$(TARGET)-gcc LUAV=$(LUA_VER_SHORT) PLAT=linux COMPAT=COMPAT LUAINC_linux=$(TARGET_INCLUDE_DIR) LUAPREFIX_linux=; \
		$(MAKE) install LUAPREFIX_linux= LUAV=$(LUA_VER_SHORT)
	$(REMOVE)/luasocket-git-$(LUASOCKET_VER)
	$(TOUCH)

#
# luasoap
#
LUASOAP_VER = 3_0_1
LUASOAP_SOURCE = luasoap-$(LUASOAP_VER).tar.gz
#LUASOAP_PATCH = luasoap-$(LUASOAP_VER).patch

$(ARCHIVE)/$(LUASOAP_SOURCE):
	$(DOWNLOAD) $(GITHUB)/tomasguisasola/luasoap/archive/refs/tags/v$(LUASOAP_VER).tar.gz -O $(ARCHIVE)/$(LUASOAP_SOURCE)

$(D)/luasoap: $(D)/bootstrap $(D)/lua $(D)/luasocket $(D)/luaexpat $(ARCHIVE)/$(LUASOAP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/luasoap-$(LUASOAP_VER)
	$(UNTAR)/$(LUASOAP_SOURCE)
	$(CHDIR)/luasoap-$(LUASOAP_VER); \
		$(call apply_patches, $(LUASOAP_PATCH)); \
		$(MAKE) install LUA_DIR=$(TARGET_SHARE_DIR)/lua/$(LUA_VER_SHORT)
	$(REMOVE)/luasoap-$(LUASOAP_VER)
	$(TOUCH)


