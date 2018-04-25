@echo off
set MATLAB=C:\PROGRA~1\MATLAB\R2018a
set MATLAB_ARCH=win64
set MATLAB_BIN="C:\Program Files\MATLAB\R2018a\bin"
set ENTRYPOINT=mexFunction
set OUTDIR=.\
set LIB_NAME=testAddOne_mex
set MEX_NAME=testAddOne_mex
set MEX_EXT=.mexw64
call setEnv.bat
echo # Make settings for testAddOne > testAddOne_mex.mki
echo COMPILER=%COMPILER%>> testAddOne_mex.mki
echo COMPFLAGS=%COMPFLAGS%>> testAddOne_mex.mki
echo OPTIMFLAGS=%OPTIMFLAGS%>> testAddOne_mex.mki
echo DEBUGFLAGS=%DEBUGFLAGS%>> testAddOne_mex.mki
echo LINKER=%LINKER%>> testAddOne_mex.mki
echo LINKFLAGS=%LINKFLAGS%>> testAddOne_mex.mki
echo LINKOPTIMFLAGS=%LINKOPTIMFLAGS%>> testAddOne_mex.mki
echo LINKDEBUGFLAGS=%LINKDEBUGFLAGS%>> testAddOne_mex.mki
echo MATLAB_ARCH=%MATLAB_ARCH%>> testAddOne_mex.mki
echo OMPFLAGS= >> testAddOne_mex.mki
echo OMPLINKFLAGS= >> testAddOne_mex.mki
echo EMC_COMPILER=msvc140>> testAddOne_mex.mki
echo EMC_CONFIG=optim>> testAddOne_mex.mki
"C:\Program Files\MATLAB\R2018a\bin\win64\gmake" -j 1 -B -f testAddOne_mex.mk
