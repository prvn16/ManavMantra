function maxEntry = getAttrMaxEntry(cdfId,attrNum)
%cdflib.getAttrMaxEntry Return last entry number of CDF variable attribute
%   maxEntry = cdflib.getAttrMaxEntry(cdfId,attrNum) returns the last entry
%   number of the variable attribute specified by attrNum in the CDF 
%   specified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetAttrMaxzEntry.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       attrnum = cdflib.getAttrNum(cdfid,'Description');
%       maxEntry = cdflib.getAttrMaxEntry(cdfid,attrnum);
%       for j = 0:maxEntry
%           entry = cdflib.getAttrEntry(cdfid,attrnum,j);
%       end
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getAttrMaxgEntry.

% Copyright 2009-2013 The MathWorks, Inc.

maxEntry = cdflibmex('getAttrMaxEntry',cdfId,attrNum);
