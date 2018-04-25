function renameAttr(cdfId,attrNum,newName)
%cdflib.renameAttr Rename existing attribute
%   cdflib.renameAttr(cdfId,attrNum,newName) renames the attribute identified
%   by attrNum in the CDF identified by cdfId.  
%   
%   This function corresponds to the CDF library C API routine 
%   CDFrenameAttr.  
%
%   Example:
%       cdfid = cdflib.create('myfile.cdf');
%       attrNum = cdflib.createAttr(cdfid,'Purpose','global_scope');
%       cdflib.renameAttr(cdfid,attrNum,'NewPurpose');
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.createAttr.

%   Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('renameAttr',cdfId,attrNum,newName);
