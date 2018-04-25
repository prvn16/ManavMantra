function extend(dataset_id, h5_size)
%H5D.extend  Extend dataset.
%
%   H5D.extend is not recommended.  Use H5D.set_extent instead.
%
%   H5D.extend(dataset_id,h5_size) extends the dataset specified by 
%   dataset_id to the size specified by h5_size.
%
%   The HDF5 group has deprecated use of this function.
%
%   See also H5D, H5D.set_extent.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Dextend', dataset_id, h5_size);            
