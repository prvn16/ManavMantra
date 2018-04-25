function mode = getValidate()
%cdflib.getValidate Return library validation mode
%   mode = cdflib.getValidate() returns the validation mode.  mode will be
%   one of the following strings:
%
%     'VALIDATEFILEon'
%     'VALIDATEFILEoff'
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetValidate.  
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib.setValidate, cdflib.getConstantValue.

%   Copyright 2009-2013 The MathWorks, Inc.

mode = cdflibmex('getValidate');
