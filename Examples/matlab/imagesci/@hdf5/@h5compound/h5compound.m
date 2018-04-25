function hObj = h5compound(varargin)
%H5COMPOUND  Constructor.
%   hdf5.h5compound is not recommended.  Use H5T instead.
%
%   See also H5T.

% Copyright 2010-2013 The MathWorks, Inc.

if (~isempty(varargin))
    hObj = hdf5.h5compound;
    hObj.setMemberNames(varargin{:});
else
    hObj = hdf5.h5compound;
end
