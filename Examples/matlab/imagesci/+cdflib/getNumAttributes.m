function nvatts = getNumAttributes(cdfId)
%cdflib.getNumAttributes Return number of variable attributes
%   numAtts = cdflib.getNumAttributes(cdfId) returns the total number of 
%   variable attributes in the CDF specified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetNumvAttributes.
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       numAttrs = cdflib.getNumAttributes(cdfid);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getNumgAttributes.

% Copyright 2009-2013 The MathWorks, Inc.

nvatts = cdflibmex('getNumvAttributes',cdfId);

