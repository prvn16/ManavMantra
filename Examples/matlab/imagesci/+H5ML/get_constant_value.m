function value = get_constant_value( constant )
%H5ML.get_constant_value Return the value corresponding to a given string.
%   This function will return the value corresponding to a given sting.
%   The string should correspond to an enumeration (e.g. 'H5_ENUM_T') or a
%   predefined identifier (e.g. 'H5T_NATIVE_INT').
%   Since the value corresponding to a given string is not guaranteed to
%   remain the same, it is almost always prefereable to use the
%   H5ML.compare_values() function instead.
%
%   Function parameters:
%     value: The value corresponding to the supplied string.
%     constant: a string which corresponds to a HDF5 enumeration or defined
%       value.
%
%   Example:
%     a = H5ML.get_constant_value('H5T_NATIVE_INT');
%

%   Copyright 2006-2013 The MathWorks, Inc.

value = H5ML.hdf5lib2('H5MLget_constant_value', constant);
