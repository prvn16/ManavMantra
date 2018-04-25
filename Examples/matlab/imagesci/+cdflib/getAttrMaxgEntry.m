function maxEntry = getAttrMaxgEntry(cdfId,attrNum)
%cdflib.getAttrMaxgEntry Return last entry number of global attribute
%   maxEntry = cdflib.getAttrMaxgEntry(cdfId,attrNum) returns the last entry
%   number of the global attribute specified by attrNum in the CDF 
%   specified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetAttrMaxgEntry.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       attrnum = cdflib.getAttrNum(cdfid,'SampleAttribute');
%       maxEntry = cdflib.getAttrMaxgEntry(cdfid,attrnum);
%       entry = cdflib.getAttrgEntry(cdfid,attrnum,maxEntry);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getAttrMaxEntry.

% Copyright 2009-2013 The MathWorks, Inc.

maxEntry = cdflibmex('getAttrMaxgEntry',cdfId,attrNum);
