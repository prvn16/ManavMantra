function sz = get_small_data_block_size(fapl_id)
%H5P.get_small_data_block_size  Return small data block size setting.
%   sz = H5P.get_small_data_block_size(fapl_id) returns the current setting 
%   for the size of the small data block. fapl_id is a file access property 
%   list identifier.
%
%   Example:
%       fid = H5F.open('example.h5');
%       fapl = H5F.get_access_plist(fid);
%       sz = H5P.get_small_data_block_size(fapl);
%       H5P.close(fapl);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_small_data_block_size.

%   Copyright 2006-2013 The MathWorks, Inc.

sz = H5ML.hdf5lib2('H5Pget_small_data_block_size', fapl_id);            
