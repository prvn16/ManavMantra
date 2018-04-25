function [ctype,cparms,cpercentage] = getCompression(cdfId)
%cdflib.getCompression Return CDF file compression settings
%   [ctype,cparms,cpercentage] = cdflib.getCompression(cdfId) returns the 
%   compression type ctype, compression parameters cparms, and the 
%   compression percentage cpercentage.  
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetCompression.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       [ctype,cparms,cpercentage] = cdflib.getCompression(cdfid);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
% 
%   See also cdflib, cdflib.setCompression, cdflib.getVarCompression, 
%   cdflib.setVarCompression.

% Copyright 2009-2013 The MathWorks, Inc.

[ctype,cparms,cpercentage] = cdflibmex('getCompression',cdfId);
