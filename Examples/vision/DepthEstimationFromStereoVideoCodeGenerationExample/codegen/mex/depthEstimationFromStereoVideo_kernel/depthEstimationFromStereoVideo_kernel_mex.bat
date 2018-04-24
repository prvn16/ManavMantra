@echo off
set MATLAB=C:\PROGRA~1\MATLAB\R2018a
set MATLAB_ARCH=win64
set MATLAB_BIN="C:\Program Files\MATLAB\R2018a\bin"
set ENTRYPOINT=mexFunction
set OUTDIR=.\
set LIB_NAME=depthEstimationFromStereoVideo_kernel_mex
set MEX_NAME=depthEstimationFromStereoVideo_kernel_mex
set MEX_EXT=.mexw64
call setEnv.bat
echo # Make settings for depthEstimationFromStereoVideo_kernel > depthEstimationFromStereoVideo_kernel_mex.mki
echo COMPILER=%COMPILER%>> depthEstimationFromStereoVideo_kernel_mex.mki
echo COMPFLAGS=%COMPFLAGS%>> depthEstimationFromStereoVideo_kernel_mex.mki
echo OPTIMFLAGS=%OPTIMFLAGS%>> depthEstimationFromStereoVideo_kernel_mex.mki
echo DEBUGFLAGS=%DEBUGFLAGS%>> depthEstimationFromStereoVideo_kernel_mex.mki
echo LINKER=%LINKER%>> depthEstimationFromStereoVideo_kernel_mex.mki
echo LINKFLAGS=%LINKFLAGS%>> depthEstimationFromStereoVideo_kernel_mex.mki
echo LINKOPTIMFLAGS=%LINKOPTIMFLAGS%>> depthEstimationFromStereoVideo_kernel_mex.mki
echo LINKDEBUGFLAGS=%LINKDEBUGFLAGS%>> depthEstimationFromStereoVideo_kernel_mex.mki
echo MATLAB_ARCH=%MATLAB_ARCH%>> depthEstimationFromStereoVideo_kernel_mex.mki
echo OMPFLAGS= >> depthEstimationFromStereoVideo_kernel_mex.mki
echo OMPLINKFLAGS= >> depthEstimationFromStereoVideo_kernel_mex.mki
echo EMC_COMPILER=msvc140>> depthEstimationFromStereoVideo_kernel_mex.mki
echo EMC_CONFIG=optim>> depthEstimationFromStereoVideo_kernel_mex.mki
"C:\Program Files\MATLAB\R2018a\bin\win64\gmake" -j 1 -B -f depthEstimationFromStereoVideo_kernel_mex.mk
