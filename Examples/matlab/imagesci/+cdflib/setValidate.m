function setValidate(mode)
%cdflib.setValidate Set the data validation mode
%   cdflib.setValidate(mode) sets the data validation mode.  mode can be
%   one of the following strings or the numeric equivalent:
%
%     'VALIDATEFILEon'
%     'VALIDATEFILEoff'
%
%   Data validation is on by default.
%
%   Example:  turn off data validation.
%       cdflib.setValidate('VALIDATEFILEoff');
%
%   This function corresponds to the CDF library C API routine 
%   CDFsetValidate.  
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getValidate, cdflib.getConstantValue.

%   Copyright 2009-2013 The MathWorks, Inc.

if ischar(mode)
	mode = cdflib.getConstantValue(mode);
end
cdflibmex('setValidate',mode);
