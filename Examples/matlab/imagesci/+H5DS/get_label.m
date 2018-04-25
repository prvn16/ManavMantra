function label = get_label(dataset_id,idx)
%H5DS.get_label  Retrieve label from specific dataset dimension.
%   label = H5DS.get_label(dataset_id,idx) retrieves the label for
%   dimension idx of the dataset dataset_id.
%
%   Note:  The ordering of the dimension scale indices are the same as the
%   HDF5 library C API. 
%
%   Example:  
%       fid = H5F.open('example.h5');
%       world_dset_id = H5D.open(fid,'/g4/world');
%       label = H5DS.get_label(world_dset_id,0);
%       H5D.close(world_dset_id);
%       H5F.close(fid);
%
%   See also H5DS, H5DS.set_label.

%   Copyright 2009-2013 The MathWorks, Inc.

label = H5ML.hdf5lib2('H5DSget_label', dataset_id, idx);            
