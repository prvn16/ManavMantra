function value = getAttrEntry(cdfId,attrNum,entryNum)
%cdflib.getAttrEntry Read variable attribute entry
%   value = cdflib.getAttrEntry(cdfId,attrNum,entryNum) reads an attribute 
%   entry for the attribute identified by attrNum and entryNum 
%   in the CDF identified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetAttrzEntry.
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       attrnum = cdflib.getAttrNum(cdfid,'Description');
%       entry = cdflib.getAttrEntry(cdfid,attrnum,0);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.putAttrEntry, cdflib.getAttrgEntry, 
%   cdflib.putAttrgEntry.


% Copyright 2009-2013 The MathWorks, Inc.

value = cdflibmex('getAttrEntry',cdfId,attrNum,entryNum);

