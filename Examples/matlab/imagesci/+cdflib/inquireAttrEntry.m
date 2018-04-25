function [datatype,numElements] = inquireAttrEntry(cdfId,attrNum,entryNum)
%cdflib.inquireAttrEntry Return information about attribute entry
%   [datatype,numElements] = cdflib.inquireAttrEntry(cdfId,attrNum,entryNum) 
%   returns the datatype and number of elements of the attribute entry 
%   specified by attrNum and entryNum.
%
%   This function corresponds to the CDF library C API routine 
%   CDFinquireAttrzEntry.
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       attrnum = cdflib.getAttrNum(cdfid,'Description');
%       [datatype,numElements] = cdflib.inquireAttrEntry(cdfid,attrnum,0);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.inquireAttr, cdflib.getAttrScope.

% Copyright 2009-2013 The MathWorks, Inc.

[datatype,numElements] = cdflibmex('inquireAttrEntry',cdfId,attrNum,entryNum);
