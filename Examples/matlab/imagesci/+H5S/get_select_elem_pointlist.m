function buf = get_select_elem_pointlist(space_id, startpoint, numpoints)
%H5S.get_select_elem_pointlist  Return points in dataspace selection.
%   points = H5S.get_select_elem_pointlist(space_id, startpoint, numpoints)
%   returns the list of element points in the current dataspace selection.
%   startpoint specifies the element point to start with and numpoints
%   specifies the total number of points.
%
%   points is a 2-dimensional array of 0-based values specifying the
%   coordinates of the elements.  If m is the rank of the dataspace and
%   then points will have size [m x numpoints].
%
%   Note:  The ordering of the coordinate points is the same as the HDF5
%   library C API.  
%
%   Example:  Determine the first two points in the current selection.
%       dims = [100 200];
%       h5_dims = fliplr(dims);
%       space_id = H5S.create_simple(2,h5_dims,h5_dims);
%       coords = [0 0; 0 199; 99 0; 99 199];
%       coords = fliplr(coords);
%       coords = coords';
%       H5S.select_elements(space_id,'H5S_SELECT_SET',coords);
%       points = H5S.get_select_elem_pointlist(space_id,0,2);
%
%   See also H5S.

%   Copyright 2006-2013 The MathWorks, Inc.

buf = H5ML.hdf5lib2('H5Sget_select_elem_pointlist', space_id, startpoint, numpoints);            
