###########################################################################
## Makefile generated for MATLAB file/project 'FaceTrackingKLTpackNGo_kernel'. 
## 
## Makefile     : FaceTrackingKLTpackNGo_kernel_rtw.mk
## Generated on : Wed Apr 18 07:13:31 2018
## MATLAB Coder version: 4.0 (R2018a)
## 
## Build Info:
## 
## Final product: $(RELATIVE_PATH_TO_ANCHOR)\FaceTrackingKLTpackNGo_kernel.exe
## Product type : executable
## 
###########################################################################

###########################################################################
## MACROS
###########################################################################

# Macro Descriptions:
# PRODUCT_NAME            Name of the system to build
# MAKEFILE                Name of this makefile
# COMPUTER                Computer type. See the MATLAB "computer" command.
# CMD_FILE                Command file

PRODUCT_NAME              = FaceTrackingKLTpackNGo_kernel
MAKEFILE                  = FaceTrackingKLTpackNGo_kernel_rtw.mk
COMPUTER                  = PCWIN64
MATLAB_ROOT               = C:\PROGRA~1\MATLAB\R2018a
MATLAB_BIN                = C:\PROGRA~1\MATLAB\R2018a\bin
MATLAB_ARCH_BIN           = $(MATLAB_BIN)\win64
MASTER_ANCHOR_DIR         = 
START_DIR                 = C:\Sumpurn\Projects\ManavYantraLib\Examples\vision\FaceTrackingKLTpackNGoExample\codegen
ARCH                      = win64
RELATIVE_PATH_TO_ANCHOR   = C:\Sumpurn\Projects\MANAVY~2\Examples\vision\FACETR~2\codegen
CMD_FILE                  = FaceTrackingKLTpackNGo_kernel_rtw.rsp
C_STANDARD_OPTS           = 
CPP_STANDARD_OPTS         = 
NODEBUG                   = 1

###########################################################################
## TOOLCHAIN SPECIFICATIONS
###########################################################################

# Toolchain Name:          Microsoft Visual C++ 2015 v14.0 | nmake (64-bit Windows)
# Supported Version(s):    14.0
# ToolchainInfo Version:   R2018a
# Specification Revision:  1.0
# 
#-------------------------------------------
# Macros assumed to be defined elsewhere
#-------------------------------------------

# NODEBUG
# cvarsdll
# cvarsmt
# conlibsmt
# ldebug
# conflags
# cflags

#-----------
# MACROS
#-----------

MEX_OPTS_FILE       = $(MATLAB_ROOT)\bin\$(ARCH)\mexopts\msvc2015.xml
MW_EXTERNLIB_DIR    = $(MATLAB_ROOT)\extern\lib\win64\microsoft
MW_LIB_DIR          = $(MATLAB_ROOT)\lib\win64
MEX_ARCH            = -win64
CPU                 = AMD64
APPVER              = 5.02
CVARSFLAG           = $(cvarsmt)
CFLAGS_ADDITIONAL   = -D_CRT_SECURE_NO_WARNINGS
CPPFLAGS_ADDITIONAL = -EHs -D_CRT_SECURE_NO_WARNINGS
LIBS_TOOLCHAIN      = $(conlibs)

TOOLCHAIN_SRCS = 
TOOLCHAIN_INCS = 
TOOLCHAIN_LIBS = 

#------------------------
# BUILD TOOL COMMANDS
#------------------------

# C Compiler: Microsoft Visual C Compiler
CC = cl

# Linker: Microsoft Visual C Linker
LD = link

# C++ Compiler: Microsoft Visual C++ Compiler
CPP = cl

# C++ Linker: Microsoft Visual C++ Linker
CPP_LD = link

# Archiver: Microsoft Visual C/C++ Archiver
AR = lib

# MEX Tool: MEX Tool
MEX_PATH = $(MATLAB_ARCH_BIN)
MEX = "$(MEX_PATH)\mex"

# Download: Download
DOWNLOAD =

# Execute: Execute
EXECUTE = $(PRODUCT)

# Builder: NMAKE Utility
MAKE = nmake


#-------------------------
# Directives/Utilities
#-------------------------

CDEBUG              = -Zi
C_OUTPUT_FLAG       = -Fo
LDDEBUG             = /DEBUG
OUTPUT_FLAG         = -out:
CPPDEBUG            = -Zi
CPP_OUTPUT_FLAG     = -Fo
CPPLDDEBUG          = /DEBUG
OUTPUT_FLAG         = -out:
ARDEBUG             =
STATICLIB_OUTPUT_FLAG = -out:
MEX_DEBUG           = -g
RM                  = @del
ECHO                = @echo
MV                  = @ren
RUN                 = @cmd /C

#----------------------------------------
# "Faster Builds" Build Configuration
#----------------------------------------

ARFLAGS              = /nologo
CFLAGS               = $(cflags) $(CVARSFLAG) $(CFLAGS_ADDITIONAL) \
                       /Od /Oy-
CPPFLAGS             = /TP $(cflags) $(CVARSFLAG) $(CPPFLAGS_ADDITIONAL) \
                       /Od /Oy-
CPP_LDFLAGS          = $(ldebug) $(conflags) $(LIBS_TOOLCHAIN)
CPP_SHAREDLIB_LDFLAGS  = $(ldebug) $(conflags) $(LIBS_TOOLCHAIN) \
                         -dll -def:$(DEF_FILE)
DOWNLOAD_FLAGS       =
EXECUTE_FLAGS        =
LDFLAGS              = $(ldebug) $(conflags) $(LIBS_TOOLCHAIN)
MEX_CPPFLAGS         = -R2018a $(MEX_ARCH) OPTIMFLAGS="/Od /Oy- $(MDFLAG) $(DEFINES)" $(MEX_OPTS_FLAG)
MEX_CPPLDFLAGS       =
MEX_CFLAGS           = -R2018a $(MEX_ARCH) OPTIMFLAGS="/Od /Oy- $(MDFLAG) $(DEFINES)" $(MEX_OPTS_FLAG)
MEX_LDFLAGS          = LDFLAGS=='$$LDFLAGS'
MAKE_FLAGS           = -f $(MAKEFILE)
SHAREDLIB_LDFLAGS    = $(ldebug) $(conflags) $(LIBS_TOOLCHAIN) \
                       -dll -def:$(DEF_FILE)

#--------------------
# File extensions
#--------------------

H_EXT               = .h
OBJ_EXT             = .obj
C_EXT               = .c
EXE_EXT             = .exe
SHAREDLIB_EXT       = .dll
HPP_EXT             = .hpp
OBJ_EXT             = .obj
CPP_EXT             = .cpp
EXE_EXT             = .exe
SHAREDLIB_EXT       = .dll
STATICLIB_EXT       = .lib
MEX_EXT             = .mexw64
MAKE_EXT            = .mk


###########################################################################
## OUTPUT INFO
###########################################################################

PRODUCT = $(RELATIVE_PATH_TO_ANCHOR)\FaceTrackingKLTpackNGo_kernel.exe
PRODUCT_TYPE = "executable"
BUILD_TYPE = "Executable"

###########################################################################
## INCLUDE PATHS
###########################################################################

INCLUDES_BUILDINFO = $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel;$(START_DIR);$(MATLAB_ROOT)\toolbox\shared\spc\src_ml\extern\include;$(MATLAB_ROOT)\toolbox\shared\dsp\vision\matlab\include;$(MATLAB_ROOT)\toolbox\vision\include;$(MATLAB_ROOT)\extern\include\multimedia;C:\Sumpurn\Projects\ManavYantraLib\Examples\vision\FaceTrackingKLTpackNGoExample;$(MATLAB_ROOT)\extern\include;$(MATLAB_ROOT)\simulink\include;$(MATLAB_ROOT)\rtw\c\src;$(MATLAB_ROOT)\rtw\c\src\ext_mode\common;$(MATLAB_ROOT)\rtw\c\ert;$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocv\include;$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\include

INCLUDES = $(INCLUDES_BUILDINFO)

###########################################################################
## DEFINES
###########################################################################

DEFINES_STANDARD = -DMODEL=FaceTrackingKLTpackNGo_kernel -DHAVESTDIO -DUSE_RTMODEL

DEFINES = $(DEFINES_STANDARD)

###########################################################################
## SOURCE FILES
###########################################################################

SRCS = $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\FaceTrackingKLTpackNGo_kernel_rtwutil.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\FaceTrackingKLTpackNGo_kernel_data.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\FaceTrackingKLTpackNGo_kernel_initialize.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\FaceTrackingKLTpackNGo_kernel_terminate.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\FaceTrackingKLTpackNGo_kernel.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\CascadeObjectDetector.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\SystemCore.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\floor.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\step.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\any.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\isequal.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\cropImage.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\abs.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\insertShape.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\repmat.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\createShapeInserter_cg.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\ShapeInserter.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\bbox2points.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\detectMinEigenFeatures.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\harrisMinEigen.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\mod.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\expandROI.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\imfilter.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\power.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\sqrt.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\findPeaks.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\imregionalmax.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\bwmorph.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\bwlookup.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\excludePointsOutsideROI.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\bsxfun.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\cornerPoints_cg.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\FeaturePointsImpl.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\PointTracker.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\estimateGeometricTransform.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\msac.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\rand.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\eml_rand_mt19937ar_stateful.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\normalizePoints.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\sum.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\svd1.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\xnrm2.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\xscal.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\xdotc.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\xaxpy.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\xrotg.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\xrot.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\xswap.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\det.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\diff.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\insertMarker.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\createMarkerInserter_cg.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\MarkerInserter.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\FaceTrackingKLTpackNGo_kernel_emxutil.c $(MATLAB_ROOT)\toolbox\shared\spc\src_ml\extern\src\DAHostLib_rtw.c $(MATLAB_ROOT)\toolbox\shared\dsp\vision\matlab\include\HostLib_MMFile.c $(MATLAB_ROOT)\toolbox\shared\dsp\vision\matlab\include\HostLib_Multimedia.c $(MATLAB_ROOT)\toolbox\vision\include\HostLib_Video.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\rt_nonfinite.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\rtGetNaN.c $(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel\rtGetInf.c C:\Sumpurn\Projects\ManavYantraLib\Examples\vision\FaceTrackingKLTpackNGoExample\main.c $(MATLAB_ROOT)\toolbox\vision\builtins\src\ocv\CascadeClassifierCore.cpp $(MATLAB_ROOT)\toolbox\vision\builtins\src\ocv\mwcascadedetect.cpp $(MATLAB_ROOT)\toolbox\vision\builtins\src\ocv\mwhaar.cpp $(MATLAB_ROOT)\toolbox\vision\builtins\src\ocv\cgCommon.cpp $(MATLAB_ROOT)\toolbox\vision\builtins\src\ocv\pointTrackerCore.cpp

ALL_SRCS = $(SRCS)

###########################################################################
## OBJECTS
###########################################################################

OBJS = FaceTrackingKLTpackNGo_kernel_rtwutil.obj FaceTrackingKLTpackNGo_kernel_data.obj FaceTrackingKLTpackNGo_kernel_initialize.obj FaceTrackingKLTpackNGo_kernel_terminate.obj FaceTrackingKLTpackNGo_kernel.obj CascadeObjectDetector.obj SystemCore.obj floor.obj step.obj any.obj isequal.obj cropImage.obj abs.obj insertShape.obj repmat.obj createShapeInserter_cg.obj ShapeInserter.obj bbox2points.obj detectMinEigenFeatures.obj harrisMinEigen.obj mod.obj expandROI.obj imfilter.obj power.obj sqrt.obj findPeaks.obj imregionalmax.obj bwmorph.obj bwlookup.obj excludePointsOutsideROI.obj bsxfun.obj cornerPoints_cg.obj FeaturePointsImpl.obj PointTracker.obj estimateGeometricTransform.obj msac.obj rand.obj eml_rand_mt19937ar_stateful.obj normalizePoints.obj sum.obj svd1.obj xnrm2.obj xscal.obj xdotc.obj xaxpy.obj xrotg.obj xrot.obj xswap.obj det.obj diff.obj insertMarker.obj createMarkerInserter_cg.obj MarkerInserter.obj FaceTrackingKLTpackNGo_kernel_emxutil.obj DAHostLib_rtw.obj HostLib_MMFile.obj HostLib_Multimedia.obj HostLib_Video.obj rt_nonfinite.obj rtGetNaN.obj rtGetInf.obj main.obj CascadeClassifierCore.obj mwcascadedetect.obj mwhaar.obj cgCommon.obj pointTrackerCore.obj

ALL_OBJS = $(OBJS)

###########################################################################
## PREBUILT OBJECT FILES
###########################################################################

PREBUILT_OBJS = 

###########################################################################
## LIBRARIES
###########################################################################

LIBS = $(MATLAB_ROOT)\extern\lib\win64\microsoft\libmwgrayto8.lib $(MATLAB_ROOT)\extern\lib\win64\microsoft\libmwrgb2gray_tbb.lib $(MATLAB_ROOT)\extern\lib\win64\microsoft\libmwippfilter.lib $(MATLAB_ROOT)\extern\lib\win64\microsoft\libmwbwlookup_tbb.lib $(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\opencv_core310.lib $(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\opencv_imgproc310.lib $(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\opencv_objdetect310.lib $(MATLAB_ROOT)\extern\lib\win64\microsoft\libmwimfilter.lib $(MATLAB_ROOT)\extern\lib\win64\microsoft\libmwimregionalmax.lib $(MATLAB_ROOT)\toolbox\vision\builtins\src\ocvcg\opencv\win64\lib\opencv_video310.lib

###########################################################################
## SYSTEM LIBRARIES
###########################################################################

SYSTEM_LIBS = 

###########################################################################
## ADDITIONAL TOOLCHAIN FLAGS
###########################################################################

#---------------
# C Compiler
#---------------

CFLAGS_BASIC = $(DEFINES) 

CFLAGS = $(CFLAGS) $(CFLAGS_BASIC)

#-----------------
# C++ Compiler
#-----------------

CPPFLAGS_BASIC = $(DEFINES) 

CPPFLAGS = $(CPPFLAGS) $(CPPFLAGS_BASIC)

###########################################################################
## INLINED COMMANDS
###########################################################################


!include $(MATLAB_ROOT)\rtw\c\tools\vcdefs.mak


###########################################################################
## PHONY TARGETS
###########################################################################

.PHONY : all build buildobj clean info prebuild download execute set_environment_variables


all : build
	@cmd /C "@echo ### Successfully generated all binary outputs."


build : set_environment_variables prebuild $(PRODUCT)


buildobj : set_environment_variables prebuild $(OBJS) $(PREBUILT_OBJS) $(LIBS)
	@cmd /C "@echo ### Successfully generated all binary outputs."


prebuild : 


download : build


execute : download
	@cmd /C "@echo ### Invoking postbuild tool "Execute" ..."
	$(EXECUTE) $(EXECUTE_FLAGS)
	@cmd /C "@echo ### Done invoking postbuild tool."


set_environment_variables : 
	@set INCLUDE=$(INCLUDES);$(INCLUDE)
	@set LIB=$(LIB)


###########################################################################
## FINAL TARGET
###########################################################################

#-------------------------------------------
# Create a standalone executable            
#-------------------------------------------

$(PRODUCT) : $(OBJS) $(PREBUILT_OBJS) $(LIBS)
	@cmd /C "@echo ### Creating standalone executable "$(PRODUCT)" ..."
	$(CPP_LD) $(CPP_LDFLAGS) -out:$(PRODUCT) @$(CMD_FILE) $(LIBS) $(SYSTEM_LIBS) $(TOOLCHAIN_LIBS)
	@cmd /C "@echo ### Created: $(PRODUCT)"


###########################################################################
## INTERMEDIATE TARGETS
###########################################################################

#---------------------
# SOURCE-TO-OBJECT
#---------------------

.c.obj :
	$(CC) $(CFLAGS) -Fo"$@" "$<"


.cpp.obj :
	$(CPP) $(CPPFLAGS) -Fo"$@" "$<"


{$(RELATIVE_PATH_TO_ANCHOR)}.c.obj :
	$(CC) $(CFLAGS) -Fo"$@" "$<"


{$(RELATIVE_PATH_TO_ANCHOR)}.cpp.obj :
	$(CPP) $(CPPFLAGS) -Fo"$@" "$<"


{$(START_DIR)}.c.obj :
	$(CC) $(CFLAGS) -Fo"$@" "$<"


{$(START_DIR)}.cpp.obj :
	$(CPP) $(CPPFLAGS) -Fo"$@" "$<"


{$(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel}.c.obj :
	$(CC) $(CFLAGS) -Fo"$@" "$<"


{$(START_DIR)\codegen\exe\FaceTrackingKLTpackNGo_kernel}.cpp.obj :
	$(CPP) $(CPPFLAGS) -Fo"$@" "$<"


{$(MATLAB_ROOT)\toolbox\shared\spc\src_ml\extern\src}.c.obj :
	$(CC) $(CFLAGS) -Fo"$@" "$<"


{$(MATLAB_ROOT)\toolbox\shared\spc\src_ml\extern\src}.cpp.obj :
	$(CPP) $(CPPFLAGS) -Fo"$@" "$<"


{$(MATLAB_ROOT)\toolbox\shared\dsp\vision\matlab\include}.c.obj :
	$(CC) $(CFLAGS) -Fo"$@" "$<"


{$(MATLAB_ROOT)\toolbox\shared\dsp\vision\matlab\include}.cpp.obj :
	$(CPP) $(CPPFLAGS) -Fo"$@" "$<"


{$(MATLAB_ROOT)\toolbox\vision\include}.c.obj :
	$(CC) $(CFLAGS) -Fo"$@" "$<"


{$(MATLAB_ROOT)\toolbox\vision\include}.cpp.obj :
	$(CPP) $(CPPFLAGS) -Fo"$@" "$<"


{C:\Sumpurn\Projects\ManavYantraLib\Examples\vision\FaceTrackingKLTpackNGoExample}.c.obj :
	$(CC) $(CFLAGS) -Fo"$@" "$<"


{C:\Sumpurn\Projects\ManavYantraLib\Examples\vision\FaceTrackingKLTpackNGoExample}.cpp.obj :
	$(CPP) $(CPPFLAGS) -Fo"$@" "$<"


{$(MATLAB_ROOT)\rtw\c\src}.c.obj :
	$(CC) $(CFLAGS) -Fo"$@" "$<"


{$(MATLAB_ROOT)\rtw\c\src}.cpp.obj :
	$(CPP) $(CPPFLAGS) -Fo"$@" "$<"


{$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocv}.c.obj :
	$(CC) $(CFLAGS) -Fo"$@" "$<"


{$(MATLAB_ROOT)\toolbox\vision\builtins\src\ocv}.cpp.obj :
	$(CPP) $(CPPFLAGS) -Fo"$@" "$<"


###########################################################################
## DEPENDENCIES
###########################################################################

$(ALL_OBJS) : $(MAKEFILE) rtw_proj.tmw


###########################################################################
## MISCELLANEOUS TARGETS
###########################################################################

info : 
	@cmd /C "@echo ### PRODUCT = $(PRODUCT)"
	@cmd /C "@echo ### PRODUCT_TYPE = $(PRODUCT_TYPE)"
	@cmd /C "@echo ### BUILD_TYPE = $(BUILD_TYPE)"
	@cmd /C "@echo ### INCLUDES = $(INCLUDES)"
	@cmd /C "@echo ### DEFINES = $(DEFINES)"
	@cmd /C "@echo ### ALL_SRCS = $(ALL_SRCS)"
	@cmd /C "@echo ### ALL_OBJS = $(ALL_OBJS)"
	@cmd /C "@echo ### LIBS = $(LIBS)"
	@cmd /C "@echo ### MODELREF_LIBS = $(MODELREF_LIBS)"
	@cmd /C "@echo ### SYSTEM_LIBS = $(SYSTEM_LIBS)"
	@cmd /C "@echo ### TOOLCHAIN_LIBS = $(TOOLCHAIN_LIBS)"
	@cmd /C "@echo ### CFLAGS = $(CFLAGS)"
	@cmd /C "@echo ### LDFLAGS = $(LDFLAGS)"
	@cmd /C "@echo ### SHAREDLIB_LDFLAGS = $(SHAREDLIB_LDFLAGS)"
	@cmd /C "@echo ### CPPFLAGS = $(CPPFLAGS)"
	@cmd /C "@echo ### CPP_LDFLAGS = $(CPP_LDFLAGS)"
	@cmd /C "@echo ### CPP_SHAREDLIB_LDFLAGS = $(CPP_SHAREDLIB_LDFLAGS)"
	@cmd /C "@echo ### ARFLAGS = $(ARFLAGS)"
	@cmd /C "@echo ### MEX_CFLAGS = $(MEX_CFLAGS)"
	@cmd /C "@echo ### MEX_CPPFLAGS = $(MEX_CPPFLAGS)"
	@cmd /C "@echo ### MEX_LDFLAGS = $(MEX_LDFLAGS)"
	@cmd /C "@echo ### MEX_CPPLDFLAGS = $(MEX_CPPLDFLAGS)"
	@cmd /C "@echo ### DOWNLOAD_FLAGS = $(DOWNLOAD_FLAGS)"
	@cmd /C "@echo ### EXECUTE_FLAGS = $(EXECUTE_FLAGS)"
	@cmd /C "@echo ### MAKE_FLAGS = $(MAKE_FLAGS)"


clean : 
	$(ECHO) "### Deleting all derived files..."
	@if exist $(PRODUCT) $(RM) $(PRODUCT)
	$(RM) $(ALL_OBJS)
	$(ECHO) "### Deleted all derived files."


