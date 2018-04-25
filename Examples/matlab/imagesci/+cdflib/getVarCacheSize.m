function numBuffers = getVarCacheSize(cdfId,varNum)
%cdflib.getVarCacheSize Return number of multi-file cache buffers
%   numBuffers = cdflib.getVarCacheSize(cdfId,varNum) returns the number of
%   cache buffers being used for the variable specified by varNum in the
%   multi-file CDF specified by cdfId.  It is not applicable to single-file
%   CDFs.  Please consult the CDF User's Guide for a discussion of caching.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetzVarCacheSize.  
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.setVarCacheSize.

%   Copyright 2009-2013 The MathWorks, Inc.

numBuffers = cdflibmex('getVarCacheSize',cdfId,varNum);
