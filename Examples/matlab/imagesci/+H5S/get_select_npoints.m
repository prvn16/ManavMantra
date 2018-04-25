function output = get_select_npoints(space_id)
%H5S.get_select_npoints  Return number of elements in dataspace selection.
%   num_points = H5S.get_select_npoints(space_id) returns the number of
%   elements in the current dataspace selection.
%  
%   Example:
%       dims = [100 200];
%       h5_dims = fliplr(dims);
%       space_id = H5S.create_simple(2,h5_dims,h5_dims);
%       op = 'H5S_SELECT_SET';
%       start = fliplr([10 20]); block = fliplr([20 30]);
%       H5S.select_hyperslab(space_id,'H5S_SELECT_SET',start,[],[],block); 
%       n = H5S.get_select_npoints(space_id);
%
%   See also H5S, H5S.create_simple, H5S.select_hyperslab.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Sget_select_npoints', space_id);            
