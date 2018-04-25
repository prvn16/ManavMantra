function setCompressionCacheSize(cdfId,numBuffers)
%cdflib.setCompressionCacheSize Specify number of compression cache buffers
%   cdflib.setCompressionCacheSize(cdfId,numBuffers) specifies the number
%   of cache buffers used for the compression scratch CDF file.  Please
%   consult the CDF User's Guide for a discussion of cache schemes.
%
%   This function corresponds to the CDF library C API routine 
%   CDFsetCompressionCacheSize.  
%
%   Example:
%       cdfid = cdflib.create('myfile.cdf');
%       cdflib.setCompressionCacheSize(cdfid,100);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
% 
%   See also cdflib, cdflib.getCompressionCacheSize.

% Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('setCompressionCacheSize',cdfId,numBuffers);
