function hObj = h5array(varargin)
%H5ARRAY  Constructor for hdf5.h5array objects
%   hdf5.h5array is not recommended.  Use H5T instead.
%
%   Example:  
%      hdf5array = hdf5.h5array;
%
%   Example:
%      hdf5array = hdf5.h5array(magic(5));
%
%   See also H5T.

%   Copyright 1984-2013 The MathWorks, Inc.

if (nargin == 1)
    hObj = hdf5.h5array;
    hObj.setData(varargin{1});
elseif (nargin == 0)
    hObj = hdf5.h5array;
else
    error(message('MATLAB:imagesci:validate:wrongNumberOfInputs'));
end
