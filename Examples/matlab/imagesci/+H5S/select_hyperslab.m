function select_hyperslab(space_id, op, h5_start, h5_stride, h5_count, h5_block)
%H5S.select_hyperslab Select hyperslab region.
%   H5S.select_hyperslab(space_id,op,h5_start,h5_stride,h5_count,h5_block)
%   selects a hyperslab region to add to the current selected region for
%   the dataspace specified by space_id. op determines how the new
%   selection is to be combined with the previously existing selection for
%   the dataspace. Possible values include: H5S_SELECT_SET, H5S_SELECT_OR,
%   H5S_SELECT_AND, H5S_SELECT_XOR, H5S_SELECT_NOTA, or H5S_SELECT_NOTB.
%   h5_start array determines the starting coordinates of the hyperslab to
%   select. h5_count array determines how many blocks to select from the
%   dataspace, in each dimension. h5_stride array specifies how many
%   elements to move in each dimension. h5_block array determines the size
%   of the element block selected from the dataspace. 
%
%   If h5_stride is specified as [], then a contiguous hyperslab is
%   selected, as if each value in h5_stride were set to 1.  If h5_count is
%   specified as [], the number of blocks selected along each dimension 
%   defaults to 1.  If h5_block is specified as [], then the block size 
%   defaults to a single element in each dimension, as if each value in the 
%   block array were set to 1.
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
%
%   See also H5S, H5S.create_simple.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Sselect_hyperslab',space_id,op,h5_start,h5_stride,h5_count,h5_block);
