function offset_simple(space_id, offset)
%H5S.offset_simple  Set offset of simple dataspace.
%   H5S.offset_simple(space_id, offset) specifies the offset of the simple
%   dataspace specified by space_id.  This function allows the same shaped
%   selection to be moved to different locations within a dataspace without
%   requiring it to be redefined.
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
%       offset = fliplr([3 5]);
%       H5S.offset_simple(space_id,offset)
%       [start,finish] = H5S.get_select_bounds(space_id);
%       start = fliplr(start);
%       finish = fliplr(finish);

%   See also H5S, H5S.get_select_bounds, H5S.select_hyperslab.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Soffset_simple', space_id, offset);            
