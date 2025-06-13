package=curl
GCCFLAGS?=
$(package)_version=8.14.1
$(package)_download_path=https://curl.haxx.se/download/
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=6766ada7101d292b42b8b15681120acd68effa4a9660935853cf6d61f0d984d4
$(package)_dependencies=openssl

define $(package)_set_vars
$(package)_config_opts+=-DBUILD_STATIC_LIBS=ON
$(package)_config_opts+=-DBUILD_SHARED_LIBS=OFF
$(package)_config_opts_mingw32+=-DCMAKE_SYSTEM_IGNORE_PATH=/usr/include
$(package)_config_opts+=-DBUILD_CURL_EXE=OFF
$(package)_config_opts+=-DBUILD_EXAMPLES=OFF
$(package)_config_opts+=-DBUILD_LIBCURL_DOCS=OFF
$(package)_config_opts+=-DBUILD_MISC_DOCS=OFF
$(package)_config_opts+=-DBUILD_TESTING=OFF
$(package)_config_opts+=-DCURL_BROTLI=OFF
$(package)_config_opts+=-DCURL_DISABLE_LDAP=ON
$(package)_config_opts+=-DCURL_ZLIB=OFF
$(package)_config_opts+=-DCURL_ZSTD=OFF
$(package)_config_opts+=-DCURL_USE_LIBPSL=OFF
$(package)_config_opts+=-DCURL_USE_LIBSSH2=OFF
$(package)_config_opts+=-DENABLE_CURL_MANUAL=OFF
$(package)_config_opts+=-DUSE_LIBIDN2=OFF
$(package)_config_opts+=-DUSE_NGHTTP2=OFF
$(package)_config_opts_linux+=-DCURL_USE_OPENSSL=ON
# Disable OpenSSL for Windows and use native SSL stack (SSPI/Schannel):
$(package)_config_opts_mingw32+=-DCURL_USE_SCHANNEL=ON
$(package)_config_opts_darwin+=-DCURL_USE_SECTRANSP=ON
# This extra flag for macOS is necessary as curl will append a -mmacosx-version-min=10.8 otherwise
# which will cause the linker to fail as it cannot optimize away a __builtin_available(MacOS 10.11...) call
# which requires a link to compiler runtime library.
$(package)_cflags_darwin=-mmacosx-version-min=$(OSX_MIN_VERSION)
$(package)_cxxflags_aarch64_linux = $(GCCFLAGS)
$(package)_cflags_aarch64_linux = $(GCCFLAGS)
$(package)_cxxflags_arm_linux = $(GCCFLAGS)
$(package)_cflags_arm_linux = $(GCCFLAGS)

ifneq ($(build_os),darwin)
$(package)_config_opts_darwin+=-DCMAKE_FRAMEWORK_PATH=$(OSX_SDK)/System/Library/Frameworks
endif

endef

define $(package)_config_cmds
  $($(package)_cmake) -S . -B .
endef

define $(package)_build_cmds
  $(MAKE)
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef
