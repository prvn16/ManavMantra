function name = getAttrName(cdfId,attrNum)
%cdflib.getAttrName Return name attached to attribute
%   name = cdflib.getAttrName(cdfId,attrNum) returns the name of the attribute
%   identified by attrNum in the CDF identified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetAttrName.  
%
%   Example:  Retrieve the name of the first attribute.
%       cdfid = cdflib.open('example.cdf');
%       attrName = cdflib.getAttrName(cdfid,0);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.createAttr.

%   Copyright 2009-2013 The MathWorks, Inc.

name = cdflibmex('getAttrName',cdfId,attrNum);
