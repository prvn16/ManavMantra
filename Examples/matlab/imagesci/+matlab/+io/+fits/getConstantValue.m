function n = getConstantValue(s)
%getConstantValue Return numeric value of named constant.
%   N = getConstantValue(NAME) returns the numeric value corresponding to 
%   the named CFITSIO constant.
%
%   Example:
%       import matlab.io.*
%       n = fits.getConstantValue('BYTE_IMG');
%
%   See also fits.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(s,{'char'},{'nonempty'},'getConstantValue','CONSTNAME');
n = fitsiolib('get_constant_value',s);
