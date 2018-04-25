function defineEnum(hObj, stringValues, numberValues)
%DEFINEENUM  Add the enum definition to the hdf5.h5enum object.
%   hdf5.h5enum.defineEnum is not recommended.  Use H5T instead.
%
%   Example:
%       HDF5ENUM = hdf5.h5enum;
%       HDF5ENUM.defineEnum({'RED','BLUE','GREEN','BLACK'}, ...
%                       uint8([1 2 3 0]);
%
%   See also H5T.

%   Copyright 1984-2013 The MathWorks, Inc.

% Parse inputs.
if (~iscellstr(stringValues))
    error(message('MATLAB:imagesci:deprecatedHDF5:badStringValueType'));
elseif (numel(stringValues) ~= numel(numberValues))
    error(message('MATLAB:imagesci:deprecatedHDF5:unbalancedValues'));
end

% Put the data.
hObj.setEnumNames(stringValues);
hObj.setEnumValues(numberValues);
