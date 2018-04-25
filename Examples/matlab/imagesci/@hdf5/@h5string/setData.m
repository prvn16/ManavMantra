function setData(hObj, data)
%SETDATA  Set the hdf5.h5string's data.
%   hdf5.h5string.setData is not recommended.  Use H5D and H5T instead.
%
%   Example:
%       HDF5STRING = hdf5.h5string;
%       HDF5STRING.setData('East Coast');
%
%   See also H5D, H5T.

%   Copyright 1984-2013 The MathWorks, Inc.

thisLength = numel(data);
maxLength = hObj.Length;

if (thisLength ~= length(data))
    error(message('MATLAB:imagesci:deprecatedHDF5:badRank'))
end

if (maxLength == 0)
    hObj.setLength(thisLength);
elseif (thisLength > maxLength)
    warning(message('MATLAB:imagesci:deprecatedHDF5:stringTruncation'))
end

hObj.Data = data;
