function set_hyper_vector_size(dxpl_id, size)
%H5P.set_hyper_vector_size  Set number of I/O vectors for hyperslab I/O.
%   H5P.set_hyper_vector_size(dxpl_id, size) sets the number of I/O vectors
%   to be accumulated in memory before being issued to the lower levels of 
%   the HDF5 library for reading or writing the actual data. dxpl_id is a
%   dataset transfer property list identifier. size specifies the number of
%   I/O vectors to accumulate in memory for I/O operations.
%
%   Example:
%       dxpl = H5P.create('H5P_DATASET_XFER');
%       H5P.set_hyper_vector_size(dxpl,2048);
%
%   See also H5P, H5P.get_hyper_vector_size.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_hyper_vector_size', dxpl_id, size);
