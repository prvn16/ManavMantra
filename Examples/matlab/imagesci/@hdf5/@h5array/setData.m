function setData(hObj, data)
%SETDATA  Set the hdf5.h5array's data.
%   hdf5.h5array.setData is not recommended.  Use H5D.write instead.
%
%   Example:
%       HDF5ARRAY = hdf5.h5array;
%       HDF5ARRAY.setData(magic(100));
%
%   See also H5D.write.

%   Copyright 1984-2013 The MathWorks, Inc.

if isempty(data)
    hObj.Data = data;
    return
end

if (((~isnumeric(data)) && (~isa(data, 'hdf5.hdf5type'))) && ...
        (~iscell(data)))
    error(message('MATLAB:imagesci:deprecatedHDF5:badType'));
end

if (isa(data, class(data(1))))
    if iscell(data)
        hObj.Data = cell2mat(data);
    else
        hObj.Data = data;
    end
else
    error(message('MATLAB:imagesci:deprecatedHDF5:differentType'));
end
