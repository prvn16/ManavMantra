function putAttrEntry(cdfId,attrNum,entryNum,cdfDatatype,entryVal)
%cdflib.putAttrEntry Write attribute entry
%   cdflib.putAttrEntry(cdfId,attrNum,entryNum,cdfDataType,entryVal) writes 
%   the attribute entry for the attribute identified by attrNum and entry 
%   number entryNum.  
%
%   cdfDatatype identifies the datatype of the attribute entry in the CDF.  
%   It should be one of the following string values or the numeric 
%   equivalent.
%
%       'CDF_BYTE'
%       'CDF_CHAR'
%       'CDF_UCHAR'
%       'CDF_INT1'
%       'CDF_UINT1'
%       'CDF_INT2'
%       'CDF_UINT2'
%       'CDF_INT4'
%       'CDF_UINT4'
%       'CDF_FLOAT'
%       'CDF_REAL4'
%       'CDF_DOUBLE'
%       'CDF_REAL8'
%       'CDF_EPOCH'
%       'CDF_EPOCH16'
%
%   If the cdf datatype is 'CDF_UCHAR', then the attribute entry value must 
%   have MATLAB class char.
%
%   This function corresponds to the CDF library C API routines 
%   CDFputAttrzEntry.  
%
%   Example:
%       cdfid = cdflib.create('myfile.cdf');
%       attrNum = cdflib.createAttr(cdfid,'Another Attribute','variable_scope');
%       entry = 'My Variable Attribute Test';
%       cdflib.putAttrEntry(cdfid,attrNum,0,'CDF_CHAR',entry);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getAttrEntry, cdflib.putAttrgEntry, 
%   cdflib.getAttrgEntry, cdflib.getConstantValue.


%   Copyright 2009-2013 The MathWorks, Inc.


if ischar(cdfDatatype)
	cdfDatatype = cdflibmex('getConstantValue',cdfDatatype);
end
cdflibmex('putAttrEntry',cdfId,attrNum,entryNum,cdfDatatype,entryVal);
