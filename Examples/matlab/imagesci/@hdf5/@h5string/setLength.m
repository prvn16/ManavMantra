function setLength(hObj, len)
%SETLENGTH  Set length of the hdf5.h5string datatype.
%   hdf5.h5string.setLength is not recommended.  Use H5T instead.
%
%   Example:
%       HDF5STRING = hdf5.h5string('East Coast');
%       HDF5STRING.setLength(20);
%
%   See also H5T.

%   Copyright 1984-2013 The MathWorks, Inc.

hObj.Length = len;
