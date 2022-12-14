#
# %CopyrightBegin%
#
# Copyright Ericsson AB 1999-2017. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# %CopyrightEnd%
#
include $(ERL_TOP)/make/target.mk
include $(ERL_TOP)/make/$(TARGET)/otp.mk

# ----------------------------------------------------
# Application version
# ----------------------------------------------------
include ../vsn.mk
VSN=$(CRYPTO_VSN)

# ----------------------------------------------------
# The following variables differ between systems.
# Set by configure.
# ----------------------------------------------------
CC = gcc
LD = gcc
SHELL = /bin/sh
LIBS = 
LDFLAGS += -shared -Wl,-Bsymbolic
CFLAGS = -Werror=undef -Werror=implicit -Werror=return-type  -Wdeclaration-after-statement -Wall -Wstrict-prototypes -Wmissing-prototypes  -D_THREAD_SAFE -D_REENTRANT -DPOSIX_THREADS -D_POSIX_THREAD_SAFE_FUNCTIONS -g -O2  -D_GNU_SOURCE -fPIC 

# From erts/configure
SSL_LIBDIR = /usr/lib
SSL_INCLUDE = -I/usr/include
SSL_CRYPTO_LIBNAME = crypto
SSL_SSL_LIBNAME = ssl

INCLUDES = $(SSL_INCLUDE) -I/home/adityau/.kerl/builds/22.0/otp_src_22.0/erts/emulator/beam -I/home/adityau/.kerl/builds/22.0/otp_src_22.0/erts/include -I/home/adityau/.kerl/builds/22.0/otp_src_22.0/erts/include/x86_64-unknown-linux-gnu -I/home/adityau/.kerl/builds/22.0/otp_src_22.0/erts/include/internal -I/home/adityau/.kerl/builds/22.0/otp_src_22.0/erts/include/internal/x86_64-unknown-linux-gnu -I/home/adityau/.kerl/builds/22.0/otp_src_22.0/erts/emulator/sys/unix -I/home/adityau/.kerl/builds/22.0/otp_src_22.0/erts/emulator/sys/common

ifeq ($(TYPE),debug)
TYPEMARKER = .debug
TYPE_FLAGS = $(subst -O3,,$(subst -O2,,$(CFLAGS))) -DDEBUG
else
ifeq ($(TYPE),valgrind)
TYPEMARKER = .valgrind
TYPE_FLAGS = $(subst -O3,,$(subst -O2,,$(CFLAGS))) -DVALGRIND
else
TYPEMARKER =
TYPE_FLAGS = $(CFLAGS)
endif
endif

# ----------------------------------------------------
# Release directory specification
# ----------------------------------------------------
RELSYSDIR = $(RELEASE_PATH)/lib/crypto-$(VSN)

# ----------------------------------------------------
# Misc Macros
# ----------------------------------------------------

PRIVDIR = ../priv
OBJDIR = $(PRIVDIR)/obj/$(TARGET)
LIBDIR = $(PRIVDIR)/lib/$(TARGET)

CRYPTO_OBJS = $(OBJDIR)/crypto$(TYPEMARKER).o \
	$(OBJDIR)/aead$(TYPEMARKER).o \
	$(OBJDIR)/aes$(TYPEMARKER).o \
	$(OBJDIR)/algorithms$(TYPEMARKER).o \
	$(OBJDIR)/api_ng$(TYPEMARKER).o \
	$(OBJDIR)/atoms$(TYPEMARKER).o \
	$(OBJDIR)/bn$(TYPEMARKER).o \
	$(OBJDIR)/cipher$(TYPEMARKER).o \
	$(OBJDIR)/cmac$(TYPEMARKER).o \
	$(OBJDIR)/dh$(TYPEMARKER).o \
	$(OBJDIR)/digest$(TYPEMARKER).o \
	$(OBJDIR)/dss$(TYPEMARKER).o \
	$(OBJDIR)/ec$(TYPEMARKER).o \
	$(OBJDIR)/ecdh$(TYPEMARKER).o \
	$(OBJDIR)/eddsa$(TYPEMARKER).o \
	$(OBJDIR)/engine$(TYPEMARKER).o \
	$(OBJDIR)/evp$(TYPEMARKER).o \
	$(OBJDIR)/fips$(TYPEMARKER).o \
	$(OBJDIR)/hash$(TYPEMARKER).o \
	$(OBJDIR)/hmac$(TYPEMARKER).o \
	$(OBJDIR)/info$(TYPEMARKER).o \
	$(OBJDIR)/math$(TYPEMARKER).o \
	$(OBJDIR)/pkey$(TYPEMARKER).o \
	$(OBJDIR)/poly1305$(TYPEMARKER).o \
	$(OBJDIR)/rand$(TYPEMARKER).o \
	$(OBJDIR)/rsa$(TYPEMARKER).o \
	$(OBJDIR)/srp$(TYPEMARKER).o
CALLBACK_OBJS = $(OBJDIR)/crypto_callback$(TYPEMARKER).o
NIF_MAKEFILE = $(PRIVDIR)/Makefile
CRYPTO_STATIC_OBJS = $(OBJDIR)/crypto_static$(TYPEMARKER).o\
	$(OBJDIR)/crypto_callback_static$(TYPEMARKER).o

NIF_ARCHIVE = $(LIBDIR)/crypto$(TYPEMARKER).a

TEST_ENGINE_OBJS = $(OBJDIR)/otp_test_engine$(TYPEMARKER).o

NIF_LIB = $(LIBDIR)/crypto$(TYPEMARKER).so
CALLBACK_LIB = $(LIBDIR)/crypto_callback$(TYPEMARKER).so
TEST_ENGINE_LIB = $(LIBDIR)/otp_test_engine$(TYPEMARKER).so

DYNAMIC_CRYPTO_LIB=yes

ifeq ($(DYNAMIC_CRYPTO_LIB),yes)
SSL_DED_LD_RUNTIME_LIBRARY_PATH = -Wl,-R/usr/lib -Wl,-R/usr/local/lib64 -Wl,-R/usr/sfw/lib64 -Wl,-R/usr/lib64 -Wl,-R/opt/local/lib64 -Wl,-R/usr/pkg/lib64 -Wl,-R/usr/local/openssl/lib64 -Wl,-R/usr/lib/openssl/lib64 -Wl,-R/usr/openssl/lib64 -Wl,-R/usr/local/ssl/lib64 -Wl,-R/usr/lib/ssl/lib64 -Wl,-R/usr/ssl/lib64 -Wl,-R/lib64 -Wl,-R/usr/local/lib -Wl,-R/usr/sfw/lib -Wl,-R/opt/local/lib -Wl,-R/usr/pkg/lib -Wl,-R/usr/local/openssl/lib -Wl,-R/usr/lib/openssl/lib -Wl,-R/usr/openssl/lib -Wl,-R/usr/local/ssl/lib -Wl,-R/usr/lib/ssl/lib -Wl,-R/usr/ssl/lib -Wl,-R/lib
CRYPTO_LINK_LIB=$(SSL_DED_LD_RUNTIME_LIBRARY_PATH) -L$(SSL_LIBDIR) -l$(SSL_CRYPTO_LIBNAME)
EXTRA_FLAGS = -DHAVE_DYNAMIC_CRYPTO_LIB
else
SSL_DED_LD_RUNTIME_LIBRARY_PATH=
CRYPTO_LINK_LIB=$(SSL_LIBDIR)/lib$(SSL_CRYPTO_LIBNAME).a 
EXTRA_FLAGS =
CRYPTO_OBJS := $(CRYPTO_OBJS) $(CALLBACK_OBJS)
CALLBACK_OBJS =
CALLBACK_LIB =
endif

ifeq ($(USING_VC),yes)
AR_OUT=-out:
AR_FLAGS=
else
AR_OUT=
ifeq ($(V),0)
AR_FLAGS=rc
else
AR_FLAGS=rcv
endif
endif

ifndef RANLIB
RANLIB=true
endif

ALL_CFLAGS = $(TYPE_FLAGS) $(EXTRA_FLAGS) $(INCLUDES)
ALL_STATIC_CFLAGS = -Werror=undef -Werror=implicit -Werror=return-type    -D_THREAD_SAFE -D_REENTRANT -DPOSIX_THREADS -D_POSIX_THREAD_SAFE_FUNCTIONS -g -O2  -D_GNU_SOURCE -DSTATIC_ERLANG_NIF -DSTATIC_ERLANG_DRIVER $(INCLUDES)

# ----------------------------------------------------
# Targets
# ----------------------------------------------------

_create_dirs := $(shell mkdir -p $(OBJDIR) $(LIBDIR))

debug opt valgrind: $(NIF_LIB) $(CALLBACK_LIB) $(TEST_ENGINE_LIB) 

static_lib: $(NIF_ARCHIVE)

$(OBJDIR)/otp_test_engine$(TYPEMARKER).o: otp_test_engine.c
	$(V_at)$(INSTALL_DIR) $(OBJDIR)
	$(V_CC) -c -o $@ $(ALL_CFLAGS) $<

$(LIBDIR)/otp_test_engine$(TYPEMARKER).so: $(TEST_ENGINE_OBJS)
	$(V_at)$(INSTALL_DIR) $(LIBDIR)
	$(V_LD) $(LDFLAGS) -o $@ $^ $(LDLIBS) $(CRYPTO_LINK_LIB)

$(LIBDIR)/otp_test_engine$(TYPEMARKER).dll: $(TEST_ENGINE_OBJS)
	$(V_at)$(INSTALL_DIR) $(LIBDIR)
	$(V_LD) $(LDFLAGS) -o $@  $(SSL_DED_LD_RUNTIME_LIBRARY_PATH) -L$(SSL_LIBDIR) $(TEST_ENGINE_OBJS) -l$(SSL_CRYPTO_LIBNAME) -l$(SSL_SSL_LIBNAME)

$(OBJDIR)/%$(TYPEMARKER).o: %.c
	$(V_at)$(INSTALL_DIR) $(OBJDIR)
	$(V_CC) -c -o $@ $(ALL_CFLAGS) $<

$(LIBDIR)/crypto$(TYPEMARKER).so: $(CRYPTO_OBJS)
	$(V_at)$(INSTALL_DIR) $(LIBDIR)
	$(V_LD) $(LDFLAGS) -o $@ $^ $(LDLIBS) $(CRYPTO_LINK_LIB)

$(OBJDIR)/%_static$(TYPEMARKER).o: %.c
	$(V_at)$(INSTALL_DIR) $(OBJDIR)
	$(V_CC) -c -o $@ $(ALL_STATIC_CFLAGS) $<

$(LIBDIR)/crypto$(TYPEMARKER).a: $(CRYPTO_STATIC_OBJS)
	$(V_AR) $(AR_FLAGS) $(AR_OUT)$@ $(CRYPTO_STATIC_OBJS)
	$(V_RANLIB) $@

$(LIBDIR)/crypto$(TYPEMARKER).dll: $(CRYPTO_OBJS)
	$(V_at)$(INSTALL_DIR) $(LIBDIR)
	$(V_LD) $(LDFLAGS) -o $@  $(SSL_DED_LD_RUNTIME_LIBRARY_PATH) -L$(SSL_LIBDIR) $(CRYPTO_OBJS) -l$(SSL_CRYPTO_LIBNAME) -l$(SSL_SSL_LIBNAME)

ifeq ($(DYNAMIC_CRYPTO_LIB),yes)
$(LIBDIR)/crypto_callback$(TYPEMARKER).so: $(CALLBACK_OBJS)
	$(INSTALL_DIR) $(LIBDIR)
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS)

$(LIBDIR)/crypto_callback$(TYPEMARKER).dll: $(CALLBACK_OBJS)
	$(INSTALL_DIR) $(LIBDIR)
	$(LD) $(LDFLAGS) -o $@ $(CALLBACK_OBJS)
endif


CLEAN_OBJS_RAW = $(CRYPTO_OBJS) $(CALLBACK_OBJS) $(CRYPTO_STATIC_OBJS) $(TEST_ENGINE_OBJS)
CLEAN_OBJS_O = $(patsubst %.debug.o,%.o,$(CLEAN_OBJS_RAW:.valgrind.o=.o))

CLEAN_LIBS_RAW = $(NIF_LIB) $(CALLBACK_LIB) $(TEST_ENGINE_LIB)
CLEAN_LIBS_SO = $(patsubst %.debug.so,%.so,$(CLEAN_LIBS_RAW:.valgrind.so=.so))

clean_dynamic_libs:
	rm -f $(CLEAN_LIBS_SO)
	rm -f $(foreach T,.valgrind.so .debug.so,$(CLEAN_LIBS_SO:.so=$T))

clean_objs:
	rm -f $(CLEAN_OBJS_O)
	rm -f $(foreach T,.valgrind.o .debug.o,$(CLEAN_OBJS_O:.o=$T))

clean: clean_objs clean_dynamic_libs
	rm -f core *~

docs:

# ----------------------------------------------------
# Release Target
# ---------------------------------------------------- 
include $(ERL_TOP)/make/otp_release_targets.mk

release_spec: opt
	$(INSTALL_DIR) "$(RELSYSDIR)/priv/obj"
	$(INSTALL_DIR) "$(RELSYSDIR)/priv/lib"
	$(INSTALL_DATA) $(NIF_MAKEFILE) "$(RELSYSDIR)/priv/obj"
	$(INSTALL_PROGRAM) $(CRYPTO_OBJS) "$(RELSYSDIR)/priv/obj"
	$(INSTALL_PROGRAM) $(NIF_LIB) "$(RELSYSDIR)/priv/lib"
ifeq ($(DYNAMIC_CRYPTO_LIB),yes)
	$(INSTALL_PROGRAM) $(CALLBACK_OBJS) "$(RELSYSDIR)/priv/obj"
	$(INSTALL_PROGRAM) $(CALLBACK_LIB) "$(RELSYSDIR)/priv/lib"
endif
	$(INSTALL_PROGRAM) $(TEST_ENGINE_OBJS) "$(RELSYSDIR)/priv/obj"
	$(INSTALL_PROGRAM) $(TEST_ENGINE_LIB) "$(RELSYSDIR)/priv/lib"

release_docs_spec:

