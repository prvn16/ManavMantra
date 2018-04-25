function output = get_select_elem_npoints(space_id)
%H5S.get_select_elem_npoints  Return number of points in selection.
%   numpoints = H5S.get_select_elem_npoints(space_id) returns the number of
%   element points in the current dataspace selection.
%
%   Example: Select the corner points of a dataspace.
%       dims = [100 200];
%       h5_dims = fliplr(dims);
%       space_id = H5S.create_simple(2,h5_dims,h5_dims);
%       coords = [0 0; 0 199; 99 0; 99 199];
%       coords = fliplr(coords);
%       coords = coords';
%       H5S.select_elements(space_id,'H5S_SELECT_SET',coords)
%       numpoints = H5S.get_select_elem_npoints(space_id);
%
%   See also H5S, H5S.select_elements.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Sget_select_elem_npoints', space_id);            
