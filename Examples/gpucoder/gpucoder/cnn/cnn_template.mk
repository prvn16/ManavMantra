###########################################################################
## Makefile generated for MATLAB file/project |>PROJNAME<|. 
## 
## Makefile     : |>MAKEFILENAME<|
## 
## Final product: |>TARGETNAME<|
## Product type : |>TARGETTYPE<|
## 
###########################################################################
#
# Copyright 2016 The MathWorks, Inc.

###########################################################################
## MACROS
##########################################################################

PRODUCT_NAME              = |>TARGETNAME<|
MAKEFILE                  = |>MAKEFILENAME<|
START_DIR                 = |>BUILDDIR<|
ARCH                      = |>ARCH<|
MATLAB                    = |>MATLABROOT<|
MATLAB_ARCH_BIN           = $(MATLABROOT)/bin/$(ARCH)

###########################################################################
## TOOLCHAIN SPECIFICATIONS
###########################################################################

# Toolchain Name:          |>TOOLCHAINNAME<|
# Supported Version(s):    |>TOOLCHAINVERSION<|

#------------------------
# BUILD TOOL COMMANDS
#------------------------

# C Compiler: NVIDIA CUDA C Compiler Driver
CC = |>CCOMPILER<|

# Linker: NVIDIA CUDA C Compiler Driver
LD = |>CLINKER<|

# C++ Compiler: NVIDIA CUDA C++ Compiler Driver
CPP = |>CPPCOMPILER<|

# C++ Linker: NVIDIA CUDA C++ Compiler Driver
CPP_LD = |>CPPLINKER<|

# Archiver: GNU Archiver
AR = |>ARCHIVER<|

# Execute: Execute
EXECUTE = $(PRODUCT)

# Builder: GMAKE Utility
MAKE_PATH = $(MATLAB)/bin/$(ARCH)
MAKE = $(MAKE_PATH)/gmake

#-------------------------
# Directives/Utilities
#-------------------------

|>DEBUGFLAGS<|

#----------------------------------------
# "Faster Builds" Build Configuration
#----------------------------------------

|>BUILDFLAGS<|

#--------------------
# File extensions
#--------------------
#
# |>FILEEXTFLAGS<|
#

###########################################################################
## OUTPUT INFO
###########################################################################

PRODUCT = $(PRODUCT_NAME)

###########################################################################
## INCLUDE PATHS
###########################################################################

INCLUDES_BUILDINFO = -I"$(START_DIR)"

INCLUDES = $(INCLUDES_BUILDINFO) |>TOOLCHAININCS<|

###########################################################################
## SOURCE FILES
###########################################################################

SRCS = |>SOURCES<|

ALL_SRCS = $(SRCS)

###########################################################################
## OBJECTS
###########################################################################

OBJS = |>OBJECTS<|

ALL_OBJS = $(OBJS)

###########################################################################
## SYSTEM LIBRARIES
###########################################################################

SYSTEM_LIBS = -L".."

TOOLCHAIN_LIBS = |>TOOLCHAINLIBS<|

###########################################################################
## PHONY TARGETS
###########################################################################

.PHONY : all build buildobj clean info


all : build
	@echo "### Successfully generated all binary outputs."


build : buildobj $(PRODUCT)


buildobj : $(OBJS)


###########################################################################
## FINAL TARGET
###########################################################################

$(PRODUCT) : $(OBJS)
	$(LD) $(LDFLAGS) |>COMPUTECAPABILITY<| -o $(PRODUCT) $(OBJS) $(SYSTEM_LIBS) $(TOOLCHAIN_LIBS)
	@echo "### Created: $(PRODUCT)"

###########################################################################
## INTERMEDIATE TARGETS
###########################################################################

#---------------------
# SOURCE-TO-OBJECT
#---------------------

%|>OBJEXT<| : %.cu
	$(CC) $(CFLAGS) |>COMPUTECAPABILITY<| $(INCLUDES) -o "$@" "$<"

%|>OBJEXT<| : %.c
	$(CC) $(CFLAGS) |>COMPUTECAPABILITY<| $(INCLUDES) -o "$@" "$<"

%|>OBJEXT<| : %.cpp
	$(CPP) $(CPPFLAGS) |>COMPUTECAPABILITY<| $(INCLUDES) -o "$@" "$<"

###########################################################################
## DEPENDENCIES
###########################################################################

$(ALL_OBJS) : $(MAKEFILE)


###########################################################################
## MISCELLANEOUS TARGETS
###########################################################################

info : 
	@echo "### PRODUCT = $(PRODUCT)"
	@echo "### PRODUCT_TYPE = $(PRODUCT_TYPE)"
	@echo "### BUILD_TYPE = $(BUILD_TYPE)"
	@echo "### INCLUDES = $(INCLUDES)"
	@echo "### DEFINES = $(DEFINES)"
	@echo "### ALL_SRCS = $(ALL_SRCS)"
	@echo "### ALL_OBJS = $(ALL_OBJS)"
	@echo "### LIBS = $(LIBS)"
	@echo "### MODELREF_LIBS = $(MODELREF_LIBS)"
	@echo "### SYSTEM_LIBS = $(SYSTEM_LIBS)"
	@echo "### TOOLCHAIN_LIBS = $(TOOLCHAIN_LIBS)"
	@echo "### CFLAGS = $(CFLAGS)"
	@echo "### LDFLAGS = $(LDFLAGS)"
	@echo "### SHAREDLIB_LDFLAGS = $(SHAREDLIB_LDFLAGS)"
	@echo "### CPPFLAGS = $(CPPFLAGS)"
	@echo "### CPP_LDFLAGS = $(CPP_LDFLAGS)"
	@echo "### CPP_SHAREDLIB_LDFLAGS = $(CPP_SHAREDLIB_LDFLAGS)"
	@echo "### ARFLAGS = $(ARFLAGS)"
	@echo "### DOWNLOAD_FLAGS = $(DOWNLOAD_FLAGS)"
	@echo "### EXECUTE_FLAGS = $(EXECUTE_FLAGS)"
	@echo "### MAKE_FLAGS = $(MAKE_FLAGS)"


clean : 
	$(ECHO) "### Deleting all derived files..."
	$(RM) $(PRODUCT)
	$(RM) $(ALL_OBJS)
	$(ECHO) "### Deleted all derived files."


