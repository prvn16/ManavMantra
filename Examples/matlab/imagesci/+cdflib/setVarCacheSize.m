function setVarCacheSize(cdfId,varNum,numBuffers)
%cdflib.setVarCacheSize Specify multi-file cache buffers
%   cdflib.setVarCacheSize(cdfId,varNum,numBuffers) specifies the number of
%   cache buffers being used for the variable specified by varNum in the
%   multi-file CDF specified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFsetzVarCacheSize.  
%
%   Example:
%       cdfid = cdflib.create('myfile.cdf');
%       cdflib.setFormat(cdfid,'MULTI_FILE');
%       varnum = cdflib.createVar(cdfid,'Time','cdf_int1',1,[],true,[]);
%       cdflib.setVarCacheSize(cdfid,varnum,5);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getVarCacheSize.

%   Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('setVarCacheSize',cdfId,varNum,numBuffers);
