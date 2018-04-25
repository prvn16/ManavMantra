function bEqual = compare_values( value1, value2 )
%H5ML.compare_values Numerically compare two HDF5 values.
%   The compare_values function will compare two values, where either or
%   both values may be represented as a string.  The values are compared
%   numerically.
%
%   Function parameters:
%     bEqual: A logical value indicating whether the two values are equal.
%     value1: The first value to be compared.
%     value2: The second value to be compared.
%
%   Example:
%     val = H5ML.get_constant_value('H5T_NATIVE_INT');
%     H5ML.compare_values(val,'H5T_NATIVE_INT')


%   Copyright 2006-2013 The MathWorks, Inc.

if isa(value1, 'char')
  v1 = H5ML.get_constant_value(value1);
elseif isa(value1, 'H5ML.id')
  v1 = value1.identifier;
else
  v1 = value1;
end

if isa(value2, 'char')
  v2 = H5ML.get_constant_value(value2);
elseif isa(value2, 'H5ML.id')
  v2 = value2.identifier;
else
  v2 = value2;
end

validateattributes(v1,{'double'},{'scalar'},'','VALUE1');
validateattributes(v2,{'double'},{'scalar'},'','VALUE2');

bEqual = (v1 == v2);
