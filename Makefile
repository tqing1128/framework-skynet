#
# 只支持 linux 和 macosx，可主动传参数，默认自动选择平台
#

PLATFORM ?= none
PLATFORMS = linux, macosx
# 自动判断平台
ifeq ($(PLATFORM), none)
	system_name = $(shell uname -s | tr A-Z a-z)
	ifeq ($(system_name), linux)
		PLATFORM = linux
	else ifeq ($(system_name), darwin)
		PLATFORM = macosx
	else
		PLATFORM = none
	endif
endif

.PHONY : none $(PLATFORMS) clean

.PHONY : default

default :
	@$(MAKE) $(PLATFORM)

# lua 库目录
LUA_LIB_PATH = lualib
$(LUA_LIB_PATH) :
	mkdir $(LUA_LIB_PATH)

# lua c 库目录，放 .o .so 文件
LUA_CLIB_PATH = luaclib
$(LUA_CLIB_PATH) :
	mkdir $(LUA_CLIB_PATH)

# lua 服务目录
LUA_SERVICE_PATH = service
$(LUA_SERVICE_PATH) :
	mkdir $(LUA_SERVICE_PATH)

# skynet 内部 lua 目录，与开源 lua 不同，第三方库必须使用该 lua 编译
LUA_INCLUDE_DIR = $(shell pwd)/skynet/3rd/lua

none :
	@echo "Invild platform: $(system_name). Only support platform(${PLATFORMS})"

linux : $(LUA_CLIB_PATH) $(LUA_LIB_PATH) $(LUA_SERVICE_PATH)
	@# 开启 https
	@# 禁用 jemalloc
	cd skynet && make $@ TLS_MODULE=ltls TLS_LIB=$(TLS_LIB) TLS_INC=$(TLS_INC) MALLOC_STATICLIB= SKYNET_DEFINES=-DNOUSE_JEMALLOC

macosx : $(LUA_CLIB_PATH) $(LUA_LIB_PATH) $(LUA_SERVICE_PATH)
	@# 开启 https
	cd skynet && make $@ TLS_MODULE=ltls TLS_LIB=$(TLS_LIB) TLS_INC=$(TLS_INC)

clean :
	cd skynet && make cleanall
	rm -f $(LUA_CLIB_PATH)/*.o
	rm -f $(LUA_CLIB_PATH)/*.so