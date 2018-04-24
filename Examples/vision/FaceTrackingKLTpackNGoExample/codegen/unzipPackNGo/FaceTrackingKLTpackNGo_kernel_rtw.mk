###########################################################################
## Makefile generated for PackNGo testing of source 'FaceTrackingKLTpackNGo_kernel'.
##
## Derivative type : EXE
##
###########################################################################

# Toolchain Name: Microsoft Visual C++ 2012 v11.0 | nmake (64-bit Windows)

SOURCE = FaceTrackingKLTpackNGo_kernel

###########################################################################
## INCLUDES
###########################################################################

BUILDINFO_INCLUDES = -I"./codegen/exe/FaceTrackingKLTpackNGo_kernel" \
-I"./R2018a/extern/include"  \
-I"./R2018a/extern/include/multimedia"  \
-I"./R2018a/toolbox/vision/include" \
-I"./R2018a/toolbox/shared/spc/src_ml/extern/include"  \
-I"./R2018a/toolbox/shared/dsp/vision/matlab/include" \
-I"./R2018a/toolbox/vision/builtins/src/ocv/include" \
-I"./R2018a/toolbox/vision/builtins/src/ocvcg/opencv/include"

###########################################################################
## DEBUG FLAGS
###########################################################################

# Debug flags are disabled by default
#DEBUG_FLAG=/Z7 
DEBUG_FLAG=

#LINKDEBUG_FLAGS=/debug
LINKDEBUG_FLAGS=


###########################################################################
## MACROS
###########################################################################

BUILDINFO_DEFINES = -DMODEL=FaceTrackingKLTpackNGo_kernel -DHAVESTDIO -DUSE_RTMODEL 
BUILDINFO_FLAGS = $(BUILDINFO_INCLUDES) $(BUILDINFO_DEFINES)

#------------------------
# BUILD TOOL COMMANDS
#------------------------

CC = cl
CPP = cl
CPP_LD = link

#------------------------
# Build Configuration
#------------------------

CFLAGS    = $(cflags) $(cvarsmt)  /wd4996 $(BUILDINFO_FLAGS) $(DEBUG_FLAG) /c
CPPFLAGS  = $(cflags) $(cvarsmt)  /wd4996  /EHsc- $(BUILDINFO_FLAGS)  $(DEBUG_FLAG) /c
LINKFLAGS = $(ldebug) $(conflags) $(conlibs) $(LINKDEBUG_FLAGS) libcpmt.lib

###########################################################################
## OUTPUT INFO
###########################################################################

DERIVATIVE = FaceTrackingKLTpackNGo_kernel.exe
EXECUTABLE = FaceTrackingKLTpackNGo_kernel.exe

###########################################################################
## OBJECTS
###########################################################################

SRCS =  main.c abs.c any.c bbox2points.c bsxfun.c bwlookup.c bwmorph.c CascadeObjectDetector.c cornerPoints_cg.c createMarkerInserter_cg.c createShapeInserter_cg.c cropImage.c det.c detectMinEigenFeatures.c diff.c eml_rand_mt19937ar_stateful.c estimateGeometricTransform.c excludePointsOutsideROI.c expandROI.c FaceTrackingKLTpackNGo_kernel.c FaceTrackingKLTpackNGo_kernel_data.c FaceTrackingKLTpackNGo_kernel_emxutil.c FaceTrackingKLTpackNGo_kernel_initialize.c FaceTrackingKLTpackNGo_kernel_rtwutil.c FaceTrackingKLTpackNGo_kernel_terminate.c FeaturePointsImpl.c findPeaks.c floor.c harrisMinEigen.c imfilter.c imregionalmax.c insertMarker.c insertShape.c isequal.c MarkerInserter.c mod.c msac.c normalizePoints.c PointTracker.c power.c rand.c repmat.c rtGetInf.c rtGetNaN.c rt_nonfinite.c ShapeInserter.c sqrt.c step.c sum.c svd1.c SystemCore.c xaxpy.c xdotc.c xnrm2.c xrot.c xrotg.c xscal.c xswap.c HostLib_MMFile.c HostLib_Multimedia.c DAHostLib_rtw.c HostLib_Video.c  CascadeClassifierCore.cpp cgCommon.cpp mwcascadedetect.cpp mwhaar.cpp pointTrackerCore.cpp

OBJS_CPP_UPPER = $(SRCS:.CPP=.obj)
OBJS_CPP_LOWER = $(OBJS_CPP_UPPER:.cpp=.obj)
OBJS_C_UPPER = $(OBJS_CPP_LOWER:.C=.obj)
OBJS = $(OBJS_C_UPPER:.c=.obj)

###########################################################################
## LIBRARIES
###########################################################################

LIBS_LIST = ".\R2018a\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\*.lib" \
".\R2018a\extern\lib\win64\microsoft\*.lib"

###########################################################################
## SYSTEM LIBRARIES
###########################################################################

SYSTEM_LIBS =

###########################################################################
## PHONY TARGETS
###########################################################################

.PHONY : all clean build

all : build
	@cmd /C "echo ### Successfully generated all binary outputs."

build : clean $(EXECUTABLE)

###########################################################################
## FINAL TARGETS
###########################################################################

#-------------------------------------------
# Executable
#-------------------------------------------

$(EXECUTABLE) : $(OBJS) $(SYSTEM_LIBS) $(LIBS)
	@cmd /C "echo ### Creating product executable ... "
	$(CPP_LD) $(LINKFLAGS) -out:$(EXECUTABLE) $(OBJS) $(LIBS_LIST) $(SYSTEM_LIBS)
	@cmd /C "echo Successfully built executable $(EXECUTABLE)"

###########################################################################
## INTERMEDIATE TARGETS
###########################################################################

#-------------------------------------------
# Source-to-object
#-------------------------------------------

# for main.c
{.}.c.obj :
	$(CC) $(CFLAGS) -Fo"$@" "$<"

# no cpp file
{.}.cpp.obj :
	$(CPP) $(CPPFLAGS) -Fo"$@" "$<"

# c file
{.\codegen\exe\FaceTrackingKLTpackNGo_kernel}.c.obj :
	$(CC) $(CFLAGS) -Fo"$@" "$<"

# no cpp file
{.\codegen\exe\FaceTrackingKLTpackNGo_kernel}.cpp.obj :
	$(CPP) $(CPPFLAGS) -Fo"$@" "$<"

# cpp file
{.\R2018a\toolbox\vision\builtins\src\ocv}.cpp.obj :
	$(CPP) $(CPPFLAGS) -Fo"$@" "$<"

# c file
{.\R2018a\toolbox\shared\dsp\vision\matlab\include}.c.obj :
	$(CC) $(CFLAGS) -Fo"$@" "$<"

# c file
{.\R2018a\toolbox\shared\spc\src_ml\extern\src}.c.obj :
	$(CC) $(CFLAGS) -Fo"$@" "$<"

# c file
{.\R2018a\toolbox\vision\include}.c.obj :
	$(CC) $(CFLAGS) -Fo"$@" "$<"

###########################################################################
## MISCELLANEOUS TARGETS
###########################################################################

clean:
	@cmd /C "echo ### No op target..."
