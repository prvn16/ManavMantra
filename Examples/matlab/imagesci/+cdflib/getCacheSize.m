function numBuffers = getCacheSize(cdfId)
%cdflib.getCacheSize Return number of cache buffers used for opened CDF file
%   numBuffers = cdflib.getCacheSize(cdfId) returns the number of cache 
%   buffers being used for a particular CDF file identified by cdfId.
%   Please consult the CDF User's Guide for a discussion of cache schemes.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetCacheSize.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       numBuffers = cdflib.getCacheSize(cdfid);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
% 
%   See also cdflib, cdflib.setCacheSize.

% Copyright 2009-2013 The MathWorks, Inc.

numBuffers = cdflibmex('getCacheSize',cdfId);
