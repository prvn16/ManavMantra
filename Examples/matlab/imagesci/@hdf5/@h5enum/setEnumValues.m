function setEnumValues(hObj, numberValues)
%SETENUMVALUES  Set the hdf5.h5enum's numeric values.
%   hdf5.h5enum.setEnumValues is not recommended.  Use H5T instead.
%
%   Example:
%       HDF5ENUM = hdf5.h5enum;
%       HDF5ENUM.setEnumNames({'ALPHA' 'RED' 'GREEN' 'BLUE'});
%       HDF5ENUM.setEnumValues(uint8([0 1 2 3]));
%
%   See also H5T.

%   Copyright 1984-2013 The MathWorks, Inc.

validateattributes(numberValues,{'int8','uint8','int16','uint16','int32','uint32','int64','uint64'},{'nonempty','vector'},'','NUMBERVALUES');

hObj.EnumValues = numberValues;
