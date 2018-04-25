function fmt = getFormat(cdfId)
%cdflib.getFormat Return file format of a CDF
%   fmt = cdflib.getFormat(cdfId) returns the file format, either 
%   'SINGLE_FILE' or 'MULTI_FILE', of a CDF file identified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetFormat.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       fmt = cdflib.getFormat(cdfid);
%       cdflib.close(cdfid);
%       fprintf('The format is %s.\n', fmt);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.setFormat, cdflib.getConstantValue.

% Copyright 2009-2013 The MathWorks, Inc.

fmt = cdflibmex('getFormat',cdfId);
