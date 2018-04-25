function setName(hObj, name)
%SETNAME  Set the hdf5.hdf5type object's name.
%   hdf5.h5type.setName is not recommended.  Use H5T instead.
%
%   Example:
%       HDF5STRING = hdf5.h5string('East Coast');
%       HDF5STRING.setLength(20);
%       HDF5STRING.setName('shared datatype #1');
%
%   See also H5T.

%   Copyright 1984-2013 The MathWorks, Inc.

hObj.Name = name;
