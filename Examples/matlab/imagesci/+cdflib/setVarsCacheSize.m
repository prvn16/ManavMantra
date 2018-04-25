function setVarsCacheSize(cdfId,numBuffers)
%cdflib.setVarsCacheSize Specify cache buffers for all CDF variables.
%   cdflib.setVarsCacheSize(cdfId,numBuffers) specifies the number of
%   cache buffers being used for all of the variables in the multi-file 
%   CDF specified by cdfId.  Please consult the CDF User's Guide for a
%   discussion of caching.
%
%   This function corresponds to the CDF library C API routine 
%   CDFsetzVarsCacheSize.  
%
%   Example:
%       cdfid = cdflib.create('myfile.cdf');
%       varnum = cdflib.createVar(cdfid,'Time','cdf_int1',1,[],true,[]);
%       cdflib.setVarsCacheSize(cdfid,6);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getVarCacheSize, cdflib.setVarCacheSize.

%   Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('setVarsCacheSize',cdfId,numBuffers);
