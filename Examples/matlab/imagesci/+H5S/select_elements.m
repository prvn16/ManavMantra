function select_elements(space_id, op, h5_coord)
%H5S.select_elements  Specify coordinates to include in selection.
%   H5S.select_elements(space_id, op, h5_coord) selects the array elements
%   to be included in the selection for the dataspace specified by
%   space_id. op determines how the new selection is to be combined with
%   the previously existing selection for the dataspace and can be 
%   specified by one of the following string values:
%   
%       'H5S_SELECT_SET'
%       'H5S_SELECT_APPEND'
%       'H5S_SELECT_PREPEND'
%
%   h5_coord is a 2-dimensional array of 0-based values specifying the 
%   coordinates of the elements being selected.  If m is the rank of
%   the dataspace and if n is the number of points, then h5_coord should 
%   be an mxn array.
%
%   Note:  The HDF5 library uses C-style ordering for multidimensional 
%   arrays, while MATLAB uses FORTRAN-style ordering. The h5_coord
%   parameter assumes coordinates have C-style ordering. Please consult
%   "Using the MATLAB Low-Level HDF5 Functions" in the MATLAB documentation
%   for more information. 
%
%   Example:  Select the corner points of a dataspace.  In this case, 
%   h5_coord should have size 2x4.
%       dims = [100 200];
%       h5_dims = fliplr(dims);
%       space_id = H5S.create_simple(2,h5_dims,h5_dims);
%       coords = [0 0; 0 199; 99 0; 99 199];
%       h5_coords = fliplr(coords);
%       h5_coords = h5_coords';
%       H5S.select_elements(space_id,'H5S_SELECT_SET',h5_coords);
% 
%   See also H5S, H5S.create_simple, H5S.get_select_elem_npoints, 
%   H5S.get_select_elem_pointlist.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Sselect_elements', space_id, op, h5_coord);            
