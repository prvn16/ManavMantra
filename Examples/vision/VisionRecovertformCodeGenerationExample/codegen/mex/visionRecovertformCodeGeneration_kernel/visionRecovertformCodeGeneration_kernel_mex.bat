@echo off
set MATLAB=C:\PROGRA~1\MATLAB\R2018a
set MATLAB_ARCH=win64
set MATLAB_BIN="C:\Program Files\MATLAB\R2018a\bin"
set ENTRYPOINT=mexFunction
set OUTDIR=.\
set LIB_NAME=visionRecovertformCodeGeneration_kernel_mex
set MEX_NAME=visionRecovertformCodeGeneration_kernel_mex
set MEX_EXT=.mexw64
call setEnv.bat
echo # Make settings for visionRecovertformCodeGeneration_kernel > visionRecovertformCodeGeneration_kernel_mex.mki
echo COMPILER=%COMPILER%>> visionRecovertformCodeGeneration_kernel_mex.mki
echo COMPFLAGS=%COMPFLAGS%>> visionRecovertformCodeGeneration_kernel_mex.mki
echo OPTIMFLAGS=%OPTIMFLAGS%>> visionRecovertformCodeGeneration_kernel_mex.mki
echo DEBUGFLAGS=%DEBUGFLAGS%>> visionRecovertformCodeGeneration_kernel_mex.mki
echo LINKER=%LINKER%>> visionRecovertformCodeGeneration_kernel_mex.mki
echo LINKFLAGS=%LINKFLAGS%>> visionRecovertformCodeGeneration_kernel_mex.mki
echo LINKOPTIMFLAGS=%LINKOPTIMFLAGS%>> visionRecovertformCodeGeneration_kernel_mex.mki
echo LINKDEBUGFLAGS=%LINKDEBUGFLAGS%>> visionRecovertformCodeGeneration_kernel_mex.mki
echo MATLAB_ARCH=%MATLAB_ARCH%>> visionRecovertformCodeGeneration_kernel_mex.mki
echo OMPFLAGS= >> visionRecovertformCodeGeneration_kernel_mex.mki
echo OMPLINKFLAGS= >> visionRecovertformCodeGeneration_kernel_mex.mki
echo EMC_COMPILER=msvc140>> visionRecovertformCodeGeneration_kernel_mex.mki
echo EMC_CONFIG=optim>> visionRecovertformCodeGeneration_kernel_mex.mki
"C:\Program Files\MATLAB\R2018a\bin\win64\gmake" -j 1 -B -f visionRecovertformCodeGeneration_kernel_mex.mk
