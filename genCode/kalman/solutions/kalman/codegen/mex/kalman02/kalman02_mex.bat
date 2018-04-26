@echo off
set MATLAB=C:\PROGRA~1\MATLAB\R2018a
set MATLAB_ARCH=win64
set MATLAB_BIN="C:\Program Files\MATLAB\R2018a\bin"
set ENTRYPOINT=mexFunction
set OUTDIR=.\
set LIB_NAME=kalman02_mex
set MEX_NAME=kalman02_mex
set MEX_EXT=.mexw64
call setEnv.bat
echo # Make settings for kalman02 > kalman02_mex.mki
echo COMPILER=%COMPILER%>> kalman02_mex.mki
echo COMPFLAGS=%COMPFLAGS%>> kalman02_mex.mki
echo OPTIMFLAGS=%OPTIMFLAGS%>> kalman02_mex.mki
echo DEBUGFLAGS=%DEBUGFLAGS%>> kalman02_mex.mki
echo LINKER=%LINKER%>> kalman02_mex.mki
echo LINKFLAGS=%LINKFLAGS%>> kalman02_mex.mki
echo LINKOPTIMFLAGS=%LINKOPTIMFLAGS%>> kalman02_mex.mki
echo LINKDEBUGFLAGS=%LINKDEBUGFLAGS%>> kalman02_mex.mki
echo MATLAB_ARCH=%MATLAB_ARCH%>> kalman02_mex.mki
echo OMPFLAGS= >> kalman02_mex.mki
echo OMPLINKFLAGS= >> kalman02_mex.mki
echo EMC_COMPILER=msvc140>> kalman02_mex.mki
echo EMC_CONFIG=optim>> kalman02_mex.mki
"C:\Program Files\MATLAB\R2018a\bin\win64\gmake" -j 1 -B -f kalman02_mex.mk
