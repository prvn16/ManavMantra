function setPadding(hObj, padding)
%SETPADDING  Set padding of hdf5.h5string datatype.
%   hdf5.h5string.setPadding is not recommended.  Use H5T instead.
%
%   Example:
%       HDF5STRING = hdf5.h5string('East Coast');
%       HDF5STRING.setLength(20);
%       HDF5STRING.setPadding('spacepad');
%
%   See also H5T.

%   Copyright 1984-2013 The MathWorks, Inc.

list = {'spacepad', 'nullterm', 'nullpad'};
padding = validatestring(padding,list);

hObj.Padding = padding;
