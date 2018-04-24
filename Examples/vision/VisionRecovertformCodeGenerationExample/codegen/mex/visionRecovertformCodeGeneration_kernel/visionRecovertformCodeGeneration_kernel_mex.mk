START_DIR = C:\Sumpurn\Projects\MANAVY~2\Examples\vision\VISION~1

MATLAB_ROOT = C:\PROGRA~1\MATLAB\R2018a
MAKEFILE = visionRecovertformCodeGeneration_kernel_mex.mk

include visionRecovertformCodeGeneration_kernel_mex.mki


SRC_FILES =  \
	visionRecovertformCodeGeneration_kernel_mexutil.c \
	visionRecovertformCodeGeneration_kernel_data.c \
	visionRecovertformCodeGeneration_kernel_initialize.c \
	visionRecovertformCodeGeneration_kernel_terminate.c \
	visionRecovertformCodeGeneration_kernel.c \
	detectSURFFeatures.c \
	validateattributes.c \
	error.c \
	all.c \
	SURFPointsImpl.c \
	FeaturePointsImpl.c \
	validatesize.c \
	all1.c \
	isequal.c \
	eml_int_forloop_overflow_check.c \
	extractFeatures.c \
	mod.c \
	scalexpAlloc.c \
	colon.c \
	cvalgMatchFeatures.c \
	sum.c \
	sqrt.c \
	mrdivide.c \
	partialSort.c \
	sub2ind.c \
	sort1.c \
	sortIdx.c \
	estimateGeometricTransform.c \
	msac.c \
	rand.c \
	eml_rand.c \
	eml_rand_mcg16807_stateful.c \
	eml_rand_shr3cong_stateful.c \
	eml_rand_mt19937ar_stateful.c \
	normalizePoints.c \
	mean.c \
	svd1.c \
	warning.c \
	any.c \
	det.c \
	xgetrf.c \
	inv.c \
	norm.c \
	imwarp.c \
	xgeqp3.c \
	_coder_visionRecovertformCodeGeneration_kernel_info.c \
	_coder_visionRecovertformCodeGeneration_kernel_api.c \
	_coder_visionRecovertformCodeGeneration_kernel_mex.c \
	visionRecovertformCodeGeneration_kernel_emxutil.c \
	fastHessianDetectorCore.cpp \
	surfCommon.cpp \
	mwsurf.cpp \
	extractSurfCore.cpp \
	cgCommon.cpp \
	c_mexapi_version.c

MEX_FILE_NAME_WO_EXT = visionRecovertformCodeGeneration_kernel_mex
MEX_FILE_NAME = $(MEX_FILE_NAME_WO_EXT).mexw64
TARGET = $(MEX_FILE_NAME)

BlockModules_LIBS = "$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\opencv_core310.lib" "$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\opencv_imgproc310.lib" "$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\opencv_features2d310.lib" "$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\opencv_flann310.lib" "$(MATLAB_ROOT)\extern\lib\win64\microsoft\libmwComputeMetric.lib" "$(MATLAB_ROOT)\extern\lib\win64\microsoft\libmwippgeotrans.lib" 
SYS_LIBS = $(BlockModules_LIBS) libmwblas.lib libmwlapack.lib 


#
#====================================================================
# gmake makefile fragment for building MEX functions using MSVC
# Copyright 2007-2016 The MathWorks, Inc.
#====================================================================
#
SHELL = cmd
OBJEXT = obj
CC = $(COMPILER)
LD = $(LINKER)
.SUFFIXES: .$(OBJEXT)

OBJLISTC = $(SRC_FILES:.c=.$(OBJEXT))
OBJLIST  = $(OBJLISTC:.cpp=.$(OBJEXT))

TARGETMT = $(TARGET).manifest
MEX = $(TARGETMT)
STRICTFP = /fp:strict

target: $(MEX)

MATLAB_INCLUDES = /I "$(MATLAB_ROOT)\simulink\include"
MATLAB_INCLUDES+= /I "$(MATLAB_ROOT)\toolbox\shared\simtargets"
SYS_INCLUDE = $(MATLAB_INCLUDES)

# Additional includes

SYS_INCLUDE += /I "$(START_DIR)\codegen\mex\visionRecovertformCodeGeneration_kernel"
SYS_INCLUDE += /I "$(START_DIR)"
SYS_INCLUDE += /I ".\interface"
SYS_INCLUDE += /I "$(MATLAB_ROOT)\extern\include"
SYS_INCLUDE += /I "$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocv\include"
SYS_INCLUDE += /I "$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\include"
SYS_INCLUDE += /I "."

DIRECTIVES = $(MEX_FILE_NAME_WO_EXT)_mex.arf
COMP_FLAGS = $(COMPFLAGS) $(OMPFLAGS)
LINK_FLAGS = $(filter-out /export:mexFunction, $(LINKFLAGS))
LINK_FLAGS += /NODEFAULTLIB:LIBCMT
ifeq ($(EMC_CONFIG),optim)
  COMP_FLAGS += $(OPTIMFLAGS) $(STRICTFP)
  LINK_FLAGS += $(LINKOPTIMFLAGS)
else
  COMP_FLAGS += $(DEBUGFLAGS)
  LINK_FLAGS += $(LINKDEBUGFLAGS)
endif
LINK_FLAGS += $(OMPLINKFLAGS)
LINK_FLAGS += /OUT:$(TARGET)
LINK_FLAGS +=  /LIBPATH:"$(MATLAB_ROOT)\extern\lib\win64\microsoft"

CFLAGS = $(COMP_FLAGS)  -DHAVE_LAPACK_CONFIG_H -DLAPACK_COMPLEX_STRUCTURE -DMW_HAVE_LAPACK_DECLS  $(USER_INCLUDE) $(SYS_INCLUDE)
CPPFLAGS = $(COMP_FLAGS)  -DHAVE_LAPACK_CONFIG_H -DLAPACK_COMPLEX_STRUCTURE -DMW_HAVE_LAPACK_DECLS  $(USER_INCLUDE) $(SYS_INCLUDE)

%.$(OBJEXT) : %.c
	$(CC) $(CFLAGS) "$<"

%.$(OBJEXT) : %.cpp
	$(CC) $(CPPFLAGS) "$<"

# Additional sources

%.$(OBJEXT) : /%.c
	$(CC) $(CFLAGS) "$<"

%.$(OBJEXT) : $(MATLAB_ROOT)\toolbox\vision\builtins\src\ocv/%.c
	$(CC) $(CFLAGS) "$<"

%.$(OBJEXT) : $(START_DIR)/%.c
	$(CC) $(CFLAGS) "$<"

%.$(OBJEXT) : $(START_DIR)\codegen\mex\visionRecovertformCodeGeneration_kernel/%.c
	$(CC) $(CFLAGS) "$<"

%.$(OBJEXT) : interface/%.c
	$(CC) $(CFLAGS) "$<"



%.$(OBJEXT) : /%.cpp
	$(CC) $(CPPFLAGS) "$<"

%.$(OBJEXT) : $(MATLAB_ROOT)\toolbox\vision\builtins\src\ocv/%.cpp
	$(CC) $(CPPFLAGS) "$<"

%.$(OBJEXT) : $(START_DIR)/%.cpp
	$(CC) $(CPPFLAGS) "$<"

%.$(OBJEXT) : $(START_DIR)\codegen\mex\visionRecovertformCodeGeneration_kernel/%.cpp
	$(CC) $(CPPFLAGS) "$<"

%.$(OBJEXT) : interface/%.cpp
	$(CC) $(CPPFLAGS) "$<"



$(TARGET): $(OBJLIST) $(MAKEFILE) $(DIRECTIVES)
	$(LD) $(LINK_FLAGS) $(OBJLIST) $(USER_LIBS) $(SYS_LIBS) @$(DIRECTIVES)
	@cmd /C "echo Build completed using compiler $(EMC_COMPILER)"

$(TARGETMT): $(TARGET)
	mt -outputresource:"$(TARGET);2" -manifest "$(TARGET).manifest"

#====================================================================

