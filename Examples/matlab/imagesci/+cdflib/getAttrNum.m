function attrNum = getAttrNum(cdfId,name)
%cdflib.getAttrNum Return attribute number
%   attrNum = cdflib.getAttrNum(cdfId,name) returns the attribute number 
%   associated with the attribute name.  
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetAttrNum.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       attrNum = cdflib.getAttrNum(cdfid,'SampleAttribute');
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.createAttr, cdflib.getAttrname

% Copyright 2009-2013 The MathWorks, Inc.

attrNum = cdflibmex('getAttrNum',cdfId,name);
