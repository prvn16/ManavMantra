function set_sieve_buf_size(fapl_id, buffer_size)
%H5P.set_sieve_buf_size  Set maximum size of data sieve buffer.
%   H5P.set_sieve_buf_size(fapl_id, buffer_size) sets size, the maximum 
%   size in bytes of the data sieve buffer, which is used by file drivers 
%   that are capable of using data sieving. fapl_id is a file access 
%   property list identifier.
%
%   Example:
%       fcpl = H5P.create('H5P_FILE_CREATE');
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       H5P.set_sieve_buf_size(fapl,131072);
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',fcpl,fapl);
%       H5F.close(fid);
%
%   See also H5P, H5P.get_sieve_buf_size.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_sieve_buf_size', fapl_id, buffer_size);            
