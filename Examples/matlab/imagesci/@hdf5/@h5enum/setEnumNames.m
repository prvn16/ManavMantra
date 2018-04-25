function setEnumNames(hObj, stringValues)
%SETENUMNAMES  Set the hdf5.h5enum's string values.
%   hdf5.h5enum.setEnumNames is not recommended.  Use H5T instead.
%
%   Example:
%       HDF5ENUM.setEnumNames({'ALPHA' 'RED' 'GREEN' 'BLUE'});
%
%   See also H5T.

%   Copyright 1984-2013 The MathWorks, Inc.

if (~iscellstr(stringValues))
    error(message('MATLAB:imagesci:deprecatedHDF5:nameValueType'));
    
elseif (numel(stringValues) ~= length(stringValues))
    error(message('MATLAB:imagesci:deprecatedHDF5:nameValueRank'));
    
end

hObj.EnumNames = stringValues;
