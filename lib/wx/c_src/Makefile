#
# %CopyrightBegin%
#
# Copyright Ericsson AB 2008-2016. All Rights Reserved.
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

include ../vsn.mk
include ../config.mk

# Darwin os have debug default install of wxWidgets 
FORCED_DEBUG = 
ifeq ($(FORCED_DEBUG),debug)
override TYPE=debug
endif

ifneq ($(TYPE),debug)
override TYPE=opt
endif

SO_EXT    = .so
OBJC_CC=gcc
OBJC_CFLAGS=

GENERAL     = wxe_driver wxe_ps_init wxe_main wxe_impl wxe_helpers wxe_callback_impl wxe_return wxe_gl
GENERAL_H   = wxe_callback_impl.h  wxe_driver.h  wxe_events.h  wxe_gl.h \
	wxe_helpers.h  wxe_impl.h  wxe_memory.h  wxe_return.h

GENERATED_F = wxe_funcs wxe_events wxe_init
GENERATED_H = gen/wxe_macros.h 

GL_H = egl_impl.h gen/glu_finit.h gen/gl_finit.h gen/gl_fdefs.h 

HAVE_OPENGL = true
OPENGL_F = gl_funcs egl_impl

include $(ERL_TOP)/make/target.mk
include $(ERL_TOP)/make/output.mk
include $(ERL_TOP)/make/$(TARGET)/otp_ded.mk

ERL_INCS= $(DED_INCLUDES)

SYS_TYPE    = x86_64-unknown-linux-gnu

GENERAL_O   = $(GENERAL:%=$(SYS_TYPE)/%.o) 
GENERATED_O = $(GENERATED_F:%=$(SYS_TYPE)/%.o)
ifeq ($(HAVE_OPENGL), true)
	GL_OBJECTS = $(OPENGL_F:%=$(SYS_TYPE)/%.o)
else
	GL_OBJECTS = 
endif

RC_FILE_EXT = o
ifeq ($(SYS_TYPE),win32)
RC_FILE     = $(SYS_TYPE)/wxe_win32.$(RC_FILE_EXT)
else 
RC_FILE     = 
endif

WX_OBJECTS  = $(GENERAL_O) $(GENERATED_O) $(RC_FILE)

OBJECTS = $(WX_OBJECTS) $(GL_OBJECTS)

TARGET_DIR = ../priv/$(SYS_TYPE)

# -O2 -funroll-loops  -ffast-math -fomit-frame-pointer 

COMMON_CFLAGS = -DPACKAGE_NAME=\"\" -DPACKAGE_TARNAME=\"\" -DPACKAGE_VERSION=\"\" -DPACKAGE_STRING=\"\" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE_URL=\"\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DSIZEOF_VOID_P=8 $(ERL_INCS) 

CC		= gcc
CXX		= g++
LD		= $(CXX)
LDFLAGS		= -shared -fPIC 
RESCOMP		= 

ifeq (false,true) 
OPT_WX_LIBS      =  
DEBUG_WX_LIBS    =  
else
OPT_WX_LIBS      =  
DEBUG_WX_LIBS    =  
endif

ifeq ($(TYPE),debug)
WX_CFLAGS	= 
CFLAGS          = -g -Wall -fPIC -g -O2 -Wno-deprecated-declarations -DDEBUG  -D_GNU_SOURCE -D_THREAD_SAFE -D_REENTRANT 
WX_CXX_FLAGS	=  
CXX_FLAGS       =  -g -Wall -fPIC -g -O2 -Wno-deprecated-declarations -DDEBUG  -D_GNU_SOURCE -D_THREAD_SAFE -D_REENTRANT
WX_LIBS		= $(DEBUG_WX_LIBS)
else
WX_CFLAGS	= 
CFLAGS          = -Werror=return-type -g -Wall -O2 -fPIC -g -O2 -Wno-deprecated-declarations -fomit-frame-pointer -fno-strict-aliasing  -D_GNU_SOURCE -D_THREAD_SAFE -D_REENTRANT 
WX_CXX_FLAGS	=  
CXX_FLAGS       = -Werror=return-type  -g -Wall -O2 -fPIC -g -O2 -Wno-deprecated-declarations -fomit-frame-pointer -fno-strict-aliasing  -D_GNU_SOURCE -D_THREAD_SAFE -D_REENTRANT
WX_LIBS		= $(OPT_WX_LIBS)
endif

GL_LIBS         = -lGL -lGLU

CC_O		= $(V_CC) -c $(CFLAGS) $(WX_CFLAGS) $(COMMON_CFLAGS)
OBJC_CC_O	= $(OBJC_CC) -c $(CFLAGS) $(OBJC_CFLAGS) $(WX_CFLAGS) $(COMMON_CFLAGS)
CXX_O		= $(V_CXX) -c $(CXX_FLAGS) $(WX_CXX_FLAGS)  $(COMMON_CFLAGS)

# Targets

opt:     $(TARGET_DIR)/wxe_driver$(SO_EXT) $(TARGET_DIR)/erl_gl$(SO_EXT)

debug:   
	@${MAKE} TYPE=debug

clean:  
	rm -f $(OBJECTS) 
	rm -f $(TARGET_DIR)/*$(SO_EXT)
	rm -f *~ erl_crash.dump

complete_clean: 
	rm -f $(OBJECTS) 
	rm -f $(GENERATED_F:%=gen/%.cpp)
	rm -f gen/gl_funcs.cpp 
	rm -f $(GENERATED_H)
	rm -f ../priv/*/*
	rm -f *~ erl_crash.dump
	rm -f Makefile

docs:	

$(GL_OBJECTS): $(GL_H)
$(WX_OBJECTS): $(GENERATED_H) $(GENERAL_H) 

$(SYS_TYPE)/%.o: %.cpp 
	$(V_at)mkdir -p $(SYS_TYPE)
	$(CXX_O) $< -o $@

$(SYS_TYPE)/%.o: %.c 
	$(V_at)mkdir -p $(SYS_TYPE)
	$(CC_O) $< -o $@

$(SYS_TYPE)/wxe_ps_init.o: wxe_ps_init.c 
	$(V_at)mkdir -p $(SYS_TYPE)
	$(cc_verbose)$(OBJC_CC_O) $< -o $@

$(SYS_TYPE)/%.o: gen/%.cpp 
	$(V_at)mkdir -p $(SYS_TYPE)
	$(CXX_O) $< -o $@

$(SYS_TYPE)/%.o: gen/%.c 
	$(V_at)mkdir -p $(SYS_TYPE)
	$(CC_O) $< -o $@

$(SYS_TYPE)/wxe_win32.$(RC_FILE_EXT): wxe_win32.rc
	$(V_at)mkdir -p $(SYS_TYPE)
	$(RESCOMP) -o $@ $< 

$(TARGET_DIR)/wxe_driver$(SO_EXT): $(WX_OBJECTS)
	$(V_at)mkdir -p $(TARGET_DIR)
	$(V_LD) $(LDFLAGS) $(WX_OBJECTS) $(WX_LIBS) -o $@

$(TARGET_DIR)/erl_gl$(SO_EXT): $(GL_OBJECTS)
	$(V_at)mkdir -p $(TARGET_DIR)
	$(V_CC) $(LDFLAGS) $(GL_OBJECTS) $(GL_LIBS) -o $@


# ----------------------------------------------------
# Release Target
# ----------------------------------------------------
include $(ERL_TOP)/make/otp_release_targets.mk
release_spec: opt
	$(INSTALL_DIR) "$(RELSYSDIR)/priv"
	$(INSTALL_DATA) ../priv/erlang-logo32.png "$(RELSYSDIR)/priv/"
	$(INSTALL_DATA) ../priv/erlang-logo64.png "$(RELSYSDIR)/priv/"
	$(INSTALL_DATA) ../priv/erlang-logo128.png "$(RELSYSDIR)/priv/"
	$(INSTALL_PROGRAM) $(TARGET_DIR)/wxe_driver$(SO_EXT) "$(RELSYSDIR)/priv/"
	$(INSTALL_PROGRAM) $(TARGET_DIR)/erl_gl$(SO_EXT) "$(RELSYSDIR)/priv/"

release_docs_spec:
