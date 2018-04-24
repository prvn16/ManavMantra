START_DIR = C:\Sumpurn\Projects\MANAVY~2\Examples\vision\DEPTHE~1

MATLAB_ROOT = C:\PROGRA~1\MATLAB\R2018a
MAKEFILE = depthEstimationFromStereoVideo_kernel_mex.mk

include depthEstimationFromStereoVideo_kernel_mex.mki


SRC_FILES =  \
	depthEstimationFromStereoVideo_kernel_mexutil.c \
	depthEstimationFromStereoVideo_kernel_data.c \
	depthEstimationFromStereoVideo_kernel_initialize.c \
	depthEstimationFromStereoVideo_kernel_terminate.c \
	depthEstimationFromStereoVideo_kernel.c \
	StereoParametersImpl.c \
	matlabCodegenHandle.c \
	floor.c \
	assertValidSizeArg.c \
	eml_int_forloop_overflow_check.c \
	validateattributes.c \
	error.c \
	validatesize.c \
	all.c \
	det.c \
	abs.c \
	xswap.c \
	isequal.c \
	ImageTransformer.c \
	strcmp.c \
	CameraParametersImpl.c \
	DeployableVideoPlayer.c \
	SystemCore.c \
	scalexpAlloc.c \
	PeopleDetector.c \
	step.c \
	rectifyStereoImages.c \
	repmat.c \
	svd1.c \
	xnrm2.c \
	sqrt.c \
	mrdivide.c \
	rdivide.c \
	xscal.c \
	xdotc.c \
	xaxpy.c \
	xrotg.c \
	xrot.c \
	unaryMinOrMax.c \
	mod.c \
	mod1.c \
	norm.c \
	rodriguesVectorToMatrix.c \
	warning.c \
	meshgrid.c \
	distortPoints.c \
	bsxfun.c \
	power.c \
	ceil.c \
	sub2ind.c \
	sum.c \
	bwtraceboundary.c \
	padarray.c \
	sort1.c \
	sortIdx.c \
	round.c \
	regionprops.c \
	bwconncomp.c \
	ind2sub.c \
	rgb2gray.c \
	disparity.c \
	indexShapeCheck.c \
	insertObjectAnnotation.c \
	insertShape.c \
	createShapeInserter_cg.c \
	ShapeInserter.c \
	insertText.c \
	_coder_depthEstimationFromStereoVideo_kernel_info.c \
	_coder_depthEstimationFromStereoVideo_kernel_api.c \
	_coder_depthEstimationFromStereoVideo_kernel_mex.c \
	depthEstimationFromStereoVideo_kernel_emxutil.c \
	DAHostLib_rtw.c \
	HostLib_MMFile.c \
	HostLib_Multimedia.c \
	HostLib_Video.c \
	HOGDescriptorCore.cpp \
	mwhog.cpp \
	mwhaar.cpp \
	mwcascadedetect.cpp \
	cgCommon.cpp \
	disparitySGBMCore.cpp \
	c_mexapi_version.c

MEX_FILE_NAME_WO_EXT = depthEstimationFromStereoVideo_kernel_mex
MEX_FILE_NAME = $(MEX_FILE_NAME_WO_EXT).mexw64
TARGET = $(MEX_FILE_NAME)

BlockModules_LIBS = "$(MATLAB_ROOT)\extern\lib\win64\microsoft\libmwremaptbb.lib" "$(MATLAB_ROOT)\extern\lib\win64\microsoft\libmwbwlookup_tbb.lib" "$(MATLAB_ROOT)\extern\lib\win64\microsoft\libmwrgb2gray_tbb.lib" "$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\opencv_core310.lib" "$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\opencv_imgproc310.lib" "$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\opencv_ml310.lib" "$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\opencv_objdetect310.lib" "$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\opencv_calib3d310.lib" "$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\opencv_features2d310.lib" "$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\opencv_flann310.lib" "$(MATLAB_ROOT)\extern\lib\win64\microsoft\libmwippreconstruct.lib" 
SYS_LIBS = $(BlockModules_LIBS) libmwblas.lib 


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

SYS_INCLUDE += /I "$(START_DIR)\codegen\mex\depthEstimationFromStereoVideo_kernel"
SYS_INCLUDE += /I "$(START_DIR)"
SYS_INCLUDE += /I ".\interface"
SYS_INCLUDE += /I "$(MATLAB_ROOT)\toolbox\shared\spc\src_ml\extern\include"
SYS_INCLUDE += /I "$(MATLAB_ROOT)\toolbox\shared\dsp\vision\matlab\include"
SYS_INCLUDE += /I "$(MATLAB_ROOT)\toolbox\vision\include"
SYS_INCLUDE += /I "$(MATLAB_ROOT)\extern\include\multimedia"
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

CFLAGS = $(COMP_FLAGS)   $(USER_INCLUDE) $(SYS_INCLUDE)
CPPFLAGS = $(COMP_FLAGS)   $(USER_INCLUDE) $(SYS_INCLUDE)

%.$(OBJEXT) : %.c
	$(CC) $(CFLAGS) "$<"

%.$(OBJEXT) : %.cpp
	$(CC) $(CPPFLAGS) "$<"

# Additional sources

%.$(OBJEXT) : /%.c
	$(CC) $(CFLAGS) "$<"

%.$(OBJEXT) : $(MATLAB_ROOT)\toolbox\shared\dsp\vision\matlab\include/%.c
	$(CC) $(CFLAGS) "$<"

%.$(OBJEXT) : $(MATLAB_ROOT)\toolbox\shared\spc\src_ml\extern\src/%.c
	$(CC) $(CFLAGS) "$<"

%.$(OBJEXT) : $(MATLAB_ROOT)\toolbox\vision\builtins\src\ocv/%.c
	$(CC) $(CFLAGS) "$<"

%.$(OBJEXT) : $(MATLAB_ROOT)\toolbox\vision\include/%.c
	$(CC) $(CFLAGS) "$<"

%.$(OBJEXT) : $(START_DIR)/%.c
	$(CC) $(CFLAGS) "$<"

%.$(OBJEXT) : $(START_DIR)\codegen\mex\depthEstimationFromStereoVideo_kernel/%.c
	$(CC) $(CFLAGS) "$<"

%.$(OBJEXT) : interface/%.c
	$(CC) $(CFLAGS) "$<"



%.$(OBJEXT) : /%.cpp
	$(CC) $(CPPFLAGS) "$<"

%.$(OBJEXT) : $(MATLAB_ROOT)\toolbox\shared\dsp\vision\matlab\include/%.cpp
	$(CC) $(CPPFLAGS) "$<"

%.$(OBJEXT) : $(MATLAB_ROOT)\toolbox\shared\spc\src_ml\extern\src/%.cpp
	$(CC) $(CPPFLAGS) "$<"

%.$(OBJEXT) : $(MATLAB_ROOT)\toolbox\vision\builtins\src\ocv/%.cpp
	$(CC) $(CPPFLAGS) "$<"

%.$(OBJEXT) : $(MATLAB_ROOT)\toolbox\vision\include/%.cpp
	$(CC) $(CPPFLAGS) "$<"

%.$(OBJEXT) : $(START_DIR)/%.cpp
	$(CC) $(CPPFLAGS) "$<"

%.$(OBJEXT) : $(START_DIR)\codegen\mex\depthEstimationFromStereoVideo_kernel/%.cpp
	$(CC) $(CPPFLAGS) "$<"

%.$(OBJEXT) : interface/%.cpp
	$(CC) $(CPPFLAGS) "$<"



$(TARGET): $(OBJLIST) $(MAKEFILE) $(DIRECTIVES)
	$(LD) $(LINK_FLAGS) $(OBJLIST) $(USER_LIBS) $(SYS_LIBS) @$(DIRECTIVES)
	@cmd /C "echo Build completed using compiler $(EMC_COMPILER)"

$(TARGETMT): $(TARGET)
	mt -outputresource:"$(TARGET);2" -manifest "$(TARGET).manifest"

#====================================================================

