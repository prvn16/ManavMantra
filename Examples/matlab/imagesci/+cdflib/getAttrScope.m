function scope = getAttrScope(cdfId,attrNum)
%cdflib.getAttrScope Return attribute scope
%   scope = cdflib.getAttrScope(cdfId,attrNum) returns the scope of the 
%   attribute identified by attrNum in the CDF identified by cdfId.
%   scope will be one of the two strings:
%
%     'global'   - the attribute applies to the CDF as a whole
%     'variable' - the attribute only applies to the variable itself
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetAttrScope.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       attrNum = cdflib.getAttrNum(cdfid,'Description');
%       attrScope = cdflib.getAttrScope(cdfid,attrNum);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.createAttr, cdflib.getAttrname.

% Copyright 2009-2013 The MathWorks, Inc.

scope = cdflibmex('getAttrScope',cdfId,attrNum);
