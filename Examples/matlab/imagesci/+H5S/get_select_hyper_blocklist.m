function buf = get_select_hyper_blocklist(space_id, startblock, numblocks)
%H5S.get_select_hyper_blocklist  Return list of hyperslab blocks.
%   blocklist = H5S.get_select_hyper_blocklist(space_id, startblock,
%   numblocks) returns a list of the hyperslab blocks currently selected.
%   space_id is a dataspace identifier. startblock specifies the block to
%   start with and numblocks specifies the number of hyperslab blocks to
%   retrieve.
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
%       start = fliplr([10 20]); block = fliplr([20 25]);
%       H5S.select_hyperslab(space_id,'H5S_SELECT_SET',start,[],[],block); 
%       start = fliplr([20 30]); block = fliplr([20 25]);
%       H5S.select_hyperslab(space_id,'H5S_SELECT_NOTB',start,[],[],block); 
%       nblocks = H5S.get_select_hyper_nblocks(space_id);
%       for j = 1:nblocks
%           hblocks{j} = H5S.get_select_hyper_blocklist(space_id,j-1,1);
%       end
%
%   See also H5S, H5S.select_hyperslab, H5S.get_select_hyper_nblocks.

%   Copyright 2006-2013 The MathWorks, Inc.

buf = H5ML.hdf5lib2('H5Sget_select_hyper_blocklist', space_id, startblock, numblocks);
