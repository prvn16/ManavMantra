function output = select_valid(space_id)
%H5S.select_valid  Determine validity of selection.
%   output = H5S.select_valid(space_id) returns a positive value if the selection 
%   of the dataspace space_id is within the extent of that dataspace, and zero 
%   if it is not.  A negative value indicates failure.
%
%   Example:
%       dims = [100 200];
%       h5_dims = fliplr(dims);
%       space_id = H5S.create_simple(2,h5_dims,h5_dims);
%       start = fliplr([90 190]); count = [11 11];
%       H5S.select_hyperslab(space_id,'H5S_SELECT_SET',start,[],count,[]); 
%       valid = H5S.select_valid(space_id);
%       
%   See also H5S, H5S.create_simple, H5S.select_hyperslab.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Sselect_valid', space_id);            
