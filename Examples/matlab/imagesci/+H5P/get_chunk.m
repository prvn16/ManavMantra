function [rank, h5_chunk_dims] = get_chunk(plist_id)
%H5P.get_chunk  Return size of chunks.
%   [rank, h5_chunk_dims] = H5P.get_chunk(plist_id) retrieves the size of 
%   chunks for the raw data of a chunked layout dataset for the dataset 
%   creation property list specified by plist_id.
%
%   Note:  The HDF5 library uses C-style ordering for multidimensional 
%   arrays, while MATLAB uses FORTRAN-style ordering. The h5_chunk_dims
%   parameter assumes C-style ordering. Please consult "Using the MATLAB 
%   Low-Level HDF5 Functions" in the MATLAB documentation for more
%   information.  
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g4/time');
%       dcpl = H5D.get_create_plist(dset_id);
%       [rank,chunk_dims] = H5P.get_chunk(dcpl);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_chunk.

%   Copyright 2006-2013 The MathWorks, Inc.

[rank, h5_chunk_dims] = H5ML.hdf5lib2('H5Pget_chunk', plist_id);            

