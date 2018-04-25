function ldir = getImportLibDirName(context)
% GETIMPORTLIBNAME returns the compiler specific import library name on
% Windows

% Copyright 2013-2015 The MathWorks, Inc.

ldir = coder.internal.importLibDir(context);