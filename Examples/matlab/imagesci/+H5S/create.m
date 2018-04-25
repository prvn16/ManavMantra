function output = create(space_type)
%H5S.create  Create new dataspace.
%   space_id = H5S.create(space_type) creates a new dataspace of the type
%   specified by space_type, which can be specified by one of the following
%   strings:
%
%       'H5S_SCALAR'
%       'H5S_SIMPLE'
%       'H5S_NULL'
%
%   space_id is the identifier for the new dataspace.
%
%   Example:  create a scalar dataspace.
%       space_id = H5S.create('H5S_SCALAR');
%       numpoints = H5S.get_simple_extent_npoints(space_id);
%
%   See also H5S, H5S.get_simple_extent_npoints.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Screate',space_type);            
output = H5ML.id(output,'H5Sclose');
