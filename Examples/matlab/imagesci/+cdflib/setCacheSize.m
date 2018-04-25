function setCacheSize(cdfId,numBuffers)
%cdflib.setCacheSize Specify number of dotCDF cache buffers
%   cdflib.setCacheSize(cdfId,numBuffers) specifies the number of cache 
%   buffers to be used for the dotCDF file when a CDF is open.
%   Please consult the CDF User's Guide for a discussion of cache schemes.
%
%   This function corresponds to the CDF library C API routine 
%   CDFsetCacheSize.  
%   
%   Example:  extend the number of cache buffers to 500.
%       cdfid = cdflib.open('example.cdf');
%       cdflib.setCacheSize(cdfid,500);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
% 
%   See also cdflib, cdflib.getCacheSize.

% Copyright 2009-2013 The MathWorks, Inc.

validateattributes(numBuffers,{'numeric'},{'scalar','>',0},'','NUMBUFFERS');
cdflibmex('setCacheSize',cdfId,numBuffers);
