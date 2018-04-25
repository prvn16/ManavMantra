function nentries = getNumAttrEntries(cdfId,attrNum)
%cdflib.getNumAttrEntries Return number of attribute entries
%   nentries = cdflib.getNumAttrEntries(cdfId,attrNum) returns the total
%   number of entries written for the attribute specified by attrNum in the 
%   CDF specified by cdfId.
%
%   This function corresponds to the CDF library C API routines
%   CDFgetNumAttrzEntries.
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       attrNum = cdflib.getAttrNum(cdfid,'Description');
%       nentries = cdflib.getNumAttrEntries(cdfid,attrNum);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getNumAttrgEntries.

% Copyright 2009-2013 The MathWorks, Inc.

nentries = cdflibmex('getNumAttrEntries',cdfId,attrNum);
