function setData(hObj, data)
%SETDATA  Set the data for the hdf5.h5enum object
%   hdf5.h5enum.setData is not recommended.  Use H5D and H5T instead.
%
%   Example:
%       HDF5ENUM = hdf5.h5enum({'ALPHA' 'RED' 'GREEN' 'BLUE'}, ...
%              uint8([0 1 2 3]));
%       HDF5ENUM.setData(uint8([3 0 1 2]));
%
%   See also H5D, H5T.

%   Copyright 1984-2013 The MathWorks, Inc.

if isempty(data)
    hObj.Data = data;
    return
end


if ((isempty(hObj.enumNames)) || (isempty(hObj.enumValues)))
    error(message('MATLAB:imagesci:deprecatedHDF5:missingEnumData'));
end

if (~isequal(class(hObj.enumValues), class(data)))
    error(message('MATLAB:imagesci:deprecatedHDF5:differentEnumType'))
elseif ((isa(data, 'single')) || (isa(data, 'double')))
    error(message('MATLAB:imagesci:deprecatedHDF5:wrongType'))
end

if (~isempty(setdiff(data(:), hObj.enumValues)))
    warning(message('MATLAB:imagesci:deprecatedHDF5:invalidValue'))
end

hObj.Data = data;
