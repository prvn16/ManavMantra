function value = getAttrgEntry(cdfId,attrNum,entryNum)
%cdflib.getAttrgEntry Read global attribute entry
%   value = cdflib.getAttrgEntry(cdfId,attrNum,entryNum) reads a global 
%   attribute entry for the attribute identified by attrNum and entryNum 
%   in the CDF identified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetAttrgEntry.  
%
%   Example:  Retrieve the first entry for the global scope attribute
%   'SampleAttribute'.
%       cdfid = cdflib.open('example.cdf');
%       attrnum = cdflib.getAttrNum(cdfid,'SampleAttribute');
%       entry = cdflib.getAttrgEntry(cdfid,attrnum,0);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.putAttrgEntry, cdflib.getAttrEntry, 
%   cdflib.putAttrEntry, cdflib.getConstantValue.


% Copyright 2009-2013 The MathWorks, Inc.

value = cdflibmex('getAttrgEntry',cdfId,attrNum,entryNum);
