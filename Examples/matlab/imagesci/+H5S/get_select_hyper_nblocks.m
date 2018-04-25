function output = get_select_hyper_nblocks(space_id)
%H5S.get_select_hyper_nblocks  Return number of hyperslab blocks.
%   num_blocks = H5S.get_select_hyper_nblocks(space_id) returns the number
%   of hyperslab blocks in the current dataspace selection.
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
%
%   See also H5S, H5S,get_select_hyper_blocklist, H5S.select_hyperslab.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Sget_select_hyper_nblocks', space_id);            
