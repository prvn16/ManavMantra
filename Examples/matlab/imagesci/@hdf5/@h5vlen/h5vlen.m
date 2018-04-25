function hObj = h5vlen(varargin)
%H5VLEN  Constructor for an hdf5.h5vlen object.
%   hdf5.h5vlen is not recommended.  Use H5READ or H5T instead.
%
%   Example:
%       HDF5STRING = hdf5.h5vlen({0 [0 1] [0 2] [0:10]});
%
%   See also H5READ, H5T.

%   Copyright 1984-2013 The MathWorks, Inc.

narginchk(0,1);
if (nargin == 1)
    hObj = hdf5.h5vlen;
    hObj.setData(varargin{1});
else
    hObj = hdf5.h5vlen;
end
