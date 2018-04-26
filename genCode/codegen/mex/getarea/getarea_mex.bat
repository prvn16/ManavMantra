@echo off
set MATLAB=C:\PROGRA~1\MATLAB\R2018a
set MATLAB_ARCH=win64
set MATLAB_BIN="C:\Program Files\MATLAB\R2018a\bin"
set ENTRYPOINT=mexFunction
set OUTDIR=.\
set LIB_NAME=getarea_mex
set MEX_NAME=getarea_mex
set MEX_EXT=.mexw64
call setEnv.bat
echo # Make settings for getarea > getarea_mex.mki
echo COMPILER=%COMPILER%>> getarea_mex.mki
echo COMPFLAGS=%COMPFLAGS%>> getarea_mex.mki
echo OPTIMFLAGS=%OPTIMFLAGS%>> getarea_mex.mki
echo DEBUGFLAGS=%DEBUGFLAGS%>> getarea_mex.mki
echo LINKER=%LINKER%>> getarea_mex.mki
echo LINKFLAGS=%LINKFLAGS%>> getarea_mex.mki
echo LINKOPTIMFLAGS=%LINKOPTIMFLAGS%>> getarea_mex.mki
echo LINKDEBUGFLAGS=%LINKDEBUGFLAGS%>> getarea_mex.mki
echo MATLAB_ARCH=%MATLAB_ARCH%>> getarea_mex.mki
echo OMPFLAGS= >> getarea_mex.mki
echo OMPLINKFLAGS= >> getarea_mex.mki
echo EMC_COMPILER=msvc140>> getarea_mex.mki
echo EMC_CONFIG=optim>> getarea_mex.mki
"C:\Program Files\MATLAB\R2018a\bin\win64\gmake" -j 1 -B -f getarea_mex.mk
