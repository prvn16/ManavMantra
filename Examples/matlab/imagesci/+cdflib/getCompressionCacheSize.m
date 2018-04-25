function numBuffers = getCompressionCacheSize(cdfId)
%cdflib.getCompressionCacheSize Return number of compression cache buffers
%   numBuffers = cdflib.getCompressionCacheSize(cdfId) returns the number
%   of cache buffers used for the compression scratch CDF file.  Please
%   consult the CDF User's Guide for a discussion of cache schemes.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetCompressionCacheSize.
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       numBuffers = cdflib.getCompressionCacheSize(cdfid);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
% 
%   See also cdflib, cdflib.setCompressionCacheSize.

% Copyright 2009-2013 The MathWorks, Inc.

numBuffers = cdflibmex('getCompressionCacheSize',cdfId);
