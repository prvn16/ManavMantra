function sz = get_sieve_buf_size(fapl_id)
%H5P.get_sieve_buf_size  Return maximum data sieve buffer size.
%   sz = H5P.get_sieve_buf_size(fapl_id) returns the current maximum 
%   size of the data sieve buffer.
%
%   Example:
%       fid = H5F.open('example.h5');
%       fapl = H5F.get_access_plist(fid);
%       sz = H5P.get_sieve_buf_size(fapl);
%       H5P.close(fapl);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_sieve_buf_size.

%   Copyright 2006-2013 The MathWorks, Inc.

sz = H5ML.hdf5lib2('H5Pget_sieve_buf_size', fapl_id);            
