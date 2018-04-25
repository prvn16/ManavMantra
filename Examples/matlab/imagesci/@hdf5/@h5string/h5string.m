function hObj = h5string(varargin)
%H5STRING  Constructor for hdf5.h5string object.
%   hdf5.h5string is not recommended.  Use h5read or H5T instead.
%
%   Example:
%       HDF5STRING = hdf5.h5string('temperature');
%
%   See also H5READ, H5T.

%   Copyright 1984-2013 The MathWorks, Inc.

if (nargin >= 1)
    if (nargin == 2)
        hObj = hdf5.h5string;
        hObj.setData(varargin{1});
        hObj.setPadding(varargin{2});
    elseif (nargin == 1)
        hObj = hdf5.h5string;
        hObj.setData(varargin{1});
        hObj.setPadding('nullterm');
    else
        error(message('MATLAB:imagesci:validate:wrongNumberOfInputs'))
    end
    
elseif (nargin == 0)
    hObj = hdf5.h5string;
    hObj.setLength(0);
    hObj.setPadding('nullterm');
end
    
