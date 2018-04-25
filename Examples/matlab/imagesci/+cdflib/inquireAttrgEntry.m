function [datatype,numElements] = inquireAttrgEntry(cdfId,attrNum,entryNum)
%cdflib.inquireAttrgEntry Return information about global attribute entry
%   [datatype,numElements] = cdflib.inquireAttrgEntry(cdfId,attrNum,entryNum) 
%   returns the datatype and number of elements of global atrribute entry 
%   specified by attrNum and entryNum.
%
%   This function corresponds to the CDF library C API routine 
%   CDFinquireAttrgEntry.
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       attrnum = cdflib.getAttrNum(cdfid,'SampleAttribute');
%       [datatype,numElements] = cdflib.inquireAttrgEntry(cdfid,attrnum,0);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.inquireAttr, cdflib.inquireAttrEntry.


% Copyright 2009-2013 The MathWorks, Inc.

[datatype,numElements] = cdflibmex('inquireAttrgEntry',cdfId,attrNum,entryNum);
