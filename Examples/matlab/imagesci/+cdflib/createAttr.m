function attrNum = createAttr(cdfId,attrName,scope)
%cdflib.createAttr Create attribute
%   attrNum = cdflib.createAttr(cdfId,attrName,scope) creates an attribute 
%   with the name attrName with the specified scope in the CDF file 
%   identified by cdfId.  scope can either be a numeric value or one of the
%   following corresponding strings:
%
%     'global_scope'   - the attribute applies to the CDF as a whole
%     'variable_scope' - the attribute only applies to the variable itself
%
%   This function corresponds to the CDF library C API routine 
%   CDFcreateAttr.  
%
%   Example:
%       cdfid = cdflib.create('myfile.cdf');
%       attrNum = cdflib.createAttr(cdfid,'purpose','global_scope');
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getAttrNum, cdflib.deleteAttr.

%   Copyright 2009-2013 The MathWorks, Inc.

if ischar(scope)
	scope = cdflibmex('getConstantValue',scope);
end
attrNum = cdflibmex('createAttr',cdfId,attrName,scope);
