function [start, finish] = get_select_bounds(space_id)
%H5S.get_select_bounds  Return bounding box of dataspace selection.
%   [start finish] = H5S.get_select_bounds(space_id) returns the
%   coordinates of the bounding box containing the current selection. start
%   contains the starting coordinates of the bounding box and finish
%   contains the coordinates of the diagonally opposite corner.
%
%   Note:  The HDF5 library uses C-style ordering for multidimensional
%   arrays, while MATLAB uses FORTRAN-style ordering. The h5_start,
%   h5_stride, h5_count and h5_block parameters assume C-style ordering.
%   Please consult "Using the MATLAB Low-Level HDF5 Functions" in the
%   MATLAB documentation for more information.
%
%   Example:
%       dims = [100 200];
%       h5_dims = fliplr(dims);
%       space_id = H5S.create_simple(2,h5_dims,h5_dims);
%       start = fliplr([10 20]); block = fliplr([20 30]);
%       H5S.select_hyperslab(space_id,'H5S_SELECT_SET',start,[],[],block); 
%       start = fliplr([30 40]); block = fliplr([20 30]);
%       H5S.select_hyperslab(space_id,'H5S_SELECT_OR',start,[],[],block); 
%       [start, finish] = H5S.get_select_bounds(space_id);
%       matlab_start = fliplr(start);
%       matlab_finish = fliplr(finish);
%
%   See also H5S, H5S.create_simple, H5S.select_hyperslab.

%   Copyright 2006-2013 The MathWorks, Inc.

[start, finish] = H5ML.hdf5lib2('H5Sget_select_bounds', space_id);            
