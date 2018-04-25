function detach_scale(dataset_id,dimscale_id,idx)
%H5DS.detach_scale  Detach dimension scale from specific dataset dimension.
%   H5DS.detach_scale(dataset_id,dimscale_id,idx) detaches dimension scale
%   dimscale_id from dimension idx of the dataset dataset_id.
%
%   Note:  The ordering of the dimension scale indices are the same as the
%   HDF5 library C API. 
%
%   See also H5DS, H5DS.attach_scale.

%   Copyright 2009-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5DSdetach_scale', dataset_id, dimscale_id, idx);            
