function hObj = h5enum(varargin)
%H5ENUM  Constructor for hdf5.h5enum objects
%   hdf5.h5enum is not recommended.  Use h5read or H5T instead.
%
%   Example:
%       HDF5ENUM = hdf5.h5enum;
%
%   Example:
%       HDF5ENUM = hdf5.h5enum({'RED' 'GREEN' 'BLUE'}, uint8([1 2 3]));
%
%   See also H5READ, H5T.

%   Copyright 1984-2013 The MathWorks, Inc.

if (nargin == 3)
    hObj = hdf5.h5enum;
    hObj.defineEnum(varargin{2}, varargin{3});
    hObj.setData(varargin{1});
elseif (nargin == 2)
    hObj = hdf5.h5enum;
    hObj.defineEnum(varargin{:});
elseif (nargin == 0)
    hObj = hdf5.h5enum;
else
    error(message('MATLAB:imagesci:validate:wrongNumberOfInputs'));
end
