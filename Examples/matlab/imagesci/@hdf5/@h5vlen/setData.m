function setData(hObj, data)
%SETDATA  Set the hdf5.h5vlen's data.
%   hdf5.h5vlen.setData is not recommended.  Use H5D and H5T instead.
%
%   Example:
%       HDF5VLEN = hdf5.h5vlen;
%       HDF5VLEN.setData({0:5 0:10});
%
%   See also H5D, H5T.

%   Copyright 1984-2013 The MathWorks, Inc.

if isempty(data)
    hObj.Data = data;
    return
end

if (numel(data) ~= length(data))
    error(message('MATLAB:imagesci:deprecatedHDF5:notVector'))
   
    if (((~isnumeric(data)) && (~isa(data, 'hdf5.hdf5type'))) && ...
        (~iscell(data)))
        error(message('MATLAB:imagesci:deprecatedHDF5:badType'))
    end

else
  if (isa(data, class(data(1))))
    if iscell(data)
        hObj.Data = cell2mat(data);
    else
        hObj.Data = data;
    end
  else
    error(message('MATLAB:imagesci:deprecatedHDF5:inconsistentType'));
  end
end
