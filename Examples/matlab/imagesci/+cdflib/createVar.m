function varNum = createVar(cdfId,varname,dtype,numElems,dims,recVariance,dimVariance)
%cdflib.createVar Create new CDF variable 
%   varNum = cdflib.createVar(cdfId,varname,datatype,numElements,dims,recVariance,dimVariance) 
%   creates a new CDF variable.  The name of the variable is given by 
%   varName.
%   
%   The datatype argument can be either a numeric value or a string 
%   corresponding to the numeric value.  Allowed string values include
%   
%       'CDF_BYTE'
%       'CDF_CHAR'
%       'CDF_INT1'
%       'CDF_UCHAR'
%       'CDF_UINT1'
%       'CDF_INT2'
%       'CDF_UINT2'
%       'CDF_INT4'
%       'CDF_UINT4'
%       'CDF_FLOAT'
%       'CDF_REAL4'
%       'CDF_REAL8'
%       'CDF_DOUBLE'
%       'CDF_EPOCH'
%       'CDF_EPOCH16'
%
%   'CDF_CHAR' and 'CDF_UCHAR' are both 1-byte datatypes in the CDF 
%   library.  Both datatypes map to MATLAB's char datatype.
%
%   The number of elements per datum is given by numElements.  This value 
%   should only be other than one when the datatype is 'cdf_char' or 
%   'cdf_uchar'. 
%
%   dims is a vector of the dimension extents.   This can be empty if
%   there are no dimension extents.
%
%   recVariance gives the record variance and should be either true or
%   false.  
%
%   The dimension variance is given by dimVariance and should be a vector 
%   of logicals.  It can be empty if there are no dimension extents.
%
%   Example: create an int8 CDF variable called 'Time' with no 
%   dimensions. It will vary across records.
%       cdfid = cdflib.create('myfile.cdf');
%       varNum = cdflib.createVar(cdfid,'Time','cdf_int1',1,[],true,[]);
%       cdflib.close(cdfid);
%
%   This function corresponds to the CDF library C API routine 
%   CDFcreatezVar.  
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.deleteVar, cdflib.closeVar.

%   Copyright 2009-2013 The MathWorks, Inc.

if ischar(dtype)
    valid_strings = { 'cdf_byte', 'cdf_char', 'cdf_int1', 'cdf_uchar', ...
               'cdf_uint1', 'cdf_int2', 'cdf_uint2', 'cdf_int4', ...
               'cdf_uint4', 'cdf_real4', 'cdf_float', ...
			   'cdf_real8', 'cdf_double', 'cdf_epoch', 'cdf_epoch16' };
    dtype = validatestring(dtype, valid_strings);
    dtype = cdflibmex('getConstantValue',dtype);
end
validateattributes(recVariance,{'numeric','logical'},{'scalar'},'','RECVARIANCE');
varNum = cdflibmex('createVar',cdfId,varname,dtype,numElems,dims,recVariance,dimVariance);
